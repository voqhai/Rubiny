var app;
function createVueApp() {
  app = new Vue({
    el: '#app',
    data: {
      sketchup: sketchup,
      search: '',
      snippets: [],
      installed: [],
      sort: 'name',
      layout: 'list',
      sortTypes: [
        { label: 'Name', value: 'name' },
        { label: 'Created', value: 'created_at' },
        { label: 'Updated', value: 'updated_at' },
      ],
      tabs: [
        { label: 'Local', value: 'local' },
        { label: 'Online', value: 'online' },
      ],
      activeTab: 'online',
      currentHover: null,
      error: {
        message: '',
        backtrace: [],
      },
      dialogException: false,
      windowWidth: window.innerWidth,
      windowHeight: window.innerHeight,
    },
    created() {
      this.fetchSnippets();
      this.onResize();
    },
    watch: {
      installed: function (newVal, oldVal) {
        this.snippets.forEach(snippet => {
          local_snippet = newVal.find(s => s.id === snippet.id)

          // Map local info to snippet
          if (local_snippet) {
            snippet.installed = true;
            snippet.shortcut = local_snippet.shortcut;
          } else {
            snippet.installed = false;
          }
        });

        this.$forceUpdate();
      },
      currentHover: function (newVal, oldVal) {
        sketchup.call('hover', newVal, oldVal);
      }
    },
    methods: {
      call: function (...args) {
        try {
          sketchup.call(...args);
        } catch (error) {
          if (error instanceof ReferenceError) {
            alert('This function is only available in SketchUp!');
          } else {
            console.error(error);
          }
        }
      },
      fetchSnippets() {
        const jsonUrl = './all_snippets.json';
        fetch(jsonUrl)
          .then(response => {
            if (!response.ok) {
              throw new Error('Network response was not ok');
            }
            return response.json();
          })
          .then(data => {
            this.snippets = data.snippets;
            // Set default database: installed, ...
            this.setDefaultInfo();

            // tell ruby is loaded json
            this.call('loaded_database', this.snippets);
          })
          .catch(error => {
            console.error('There has been a problem with your fetch operation:', error);
          });
      },
      setDefaultInfo() {
        this.snippets.forEach(snippet => {
          snippet.installed = false;
          snippet.loaded = false;
        });
      },
      setRubyContent(filename, content) {
        const snippet = this.snippets.find(s => s.ruby_file === filename);
        if (snippet) {
          snippet.ruby_content = content;

          // After has ruby content, now we can get value of snippet by run ruby code
          if (snippet.component) {
            sketchup.call('get_value', snippet);
          }
        }
      },
      setSnippetValue(id, value) {
        console.log('Setting value for snippet:', id, value);
        s = this.snippets.find(s => s.id === id);
        if (s) {
          s.value = value;
        }
      },
      loadedSnippet(id) {
        s = this.snippets.find(s => s.id === id);
        if (s) {
          s.loaded = true;
        }
      },
      hasNewVersion(snippet) {
        i = this.installed.find(s => s.id === snippet.id)
        if (i) {
          return i.version != snippet.version;
        }

        return false;
      },
      playValue(snippet) {
        console.log('Updating snippet:', snippet, snippet.value);
        this.call('play_value', snippet);
      },
      play(snippet){
        this.call('play', snippet);
      },
      install(snippet){
        this.call('install', snippet);
      },
      uninstall(snippet){
        this.call('uninstall', snippet);
      },
      uninstalledSnippet(id, stauts) {
        if (stauts) {
          this.$message({
            message: 'Uninstall successfully! Maybe you need to restart SketchUp to apply changes.',
            type: 'success'
          });
        }
        else {
          this.$message({
            message: 'Uninstall failed!',
            type: 'error'
          });
        }
      },
      update(snippet){
        this.call('update', snippet);
      },
      updatedSnippet(id, stauts) {
        if (stauts) {
          this.$message({
            message: 'Update successfully! Maybe you need to restart SketchUp to apply changes.',
            type: 'success'
          });
        }
        else {
          this.$message({
            message: 'Update failed!',
            type: 'error'
          });
        }
      },
      showSettings(snippet){
        this.call('show_settings', snippet);
      },
      onResize() {
        this.windowWidth = window.innerWidth;
        this.windowHeight = window.innerHeight;
        if (this.windowWidth < 768) {
          this.layout = 'list';
        }
        else {
          this.layout = 'grid';
        }
      },
      sortSnippets(snippets, propName) {
        return snippets.sort((a, b) => {
          let propA = a[propName];
          let propB = b[propName];
      
          // Đối với ngày tháng, chuyển đổi thành Date object để so sánh
          if (propName === "created_at" || propName === "updated_at") {
            propA = new Date(propA);
            propB = new Date(propB);
          }
      
          if (propA < propB) {
            return -1;
          }
          if (propA > propB) {
            return 1;
          }
          return 0; // không có sự thay đổi về thứ tự
        });
      },
      hoverStart(snippet) {
        this.currentHover = snippet;
      },
      hoverEnd() {
        this.currentHover = null;
      },
      toggleLayout() {
        if (this.layout === 'grid') {
          this.layout = 'list';
        } else {
          this.layout = 'grid';
        }
      },
      handleException(error) {
        this.error = error;
        this.dialogException = true;
      },
      createIssue() {
        sketchup.call('create_issue', this.error);
      },
      // showHelp() {
      //   sketchup.call('show_help');
      // }
    },
    computed: {
      filteredSnippets() {
        var currentList;
        if (this.activeTab === 'local') {
          currentList = this.installed;
        } else {
          currentList = this.snippets;
        }

        sorted = this.sortSnippets(currentList, this.sort);
        return sorted.filter(snippet => {
          const search = this.search.toLowerCase();
          return snippet.name.toLowerCase().includes(search) || snippet.description.toLowerCase().includes(search);
        });
      },
      layoutSnippets() {
        if (this.layout === 'grid') {
          return {
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
            gridGap: '0.5rem',
          };
        } else {
          return {
            display: 'block',
            height: this.windowHeight - 200 + 'px'
          };
        }
      }
    },
    mounted() {
      try {
        sketchup.ready();
      } catch (error) {
        console.error(error);        
      }

      // Add event resize for window
      window.addEventListener('resize', this.onResize);
    },
  });
}

document.addEventListener('DOMContentLoaded', function () {
  createVueApp();
});

function loadAndProcessZip(url) {
  console.log(`Loading and processing ZIP from ${url}`);
  // Tải file ZIP
  fetch(url, {
    headers: {
      'Cache-Control': 'no-cache'
    }
  })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.blob();
    })
    .then(blob => {
      // Sử dụng JSZip để đọc nội dung file ZIP
      return JSZip.loadAsync(blob);
    })
    .then(zip => {
      // Duyệt qua tất cả các file trong ZIP
      Object.keys(zip.files).forEach(filename => {
        zip.files[filename].async('string').then(content => {
          // console.log(`File ${filename} has content:`, content);
          // Map with json data in vue
          app.setRubyContent(filename, content);
          
          // sendToRuby(filename, content);
        });
      });
    })
    .catch(err => {
      console.error('Error loading or processing zip:', err);
    });
}

// Giả sử sendToRuby là hàm bạn sẽ định nghĩa để gửi nội dung xuống Ruby
function sendToRuby(filename, content) {
  console.log(`Sending ${filename} to Ruby...`);
  console.log(`Content: ${content}`);
  try {
    sketchup.call('loadrb', filename, content)
  } catch (error) {
    console.error(error);
  }
}

console.log("Rubiny plugin page loaded successfully!");
