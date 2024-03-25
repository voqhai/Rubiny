var app;
function createVueApp() {
  app = new Vue({
    el: '#app',
    data: {
      search: '',
      snippets: [],
      installed: [],
    },
    created() {
      this.fetchSnippets();
    },
    watch: {
      installed: function (newVal, oldVal) {
        this.snippets.forEach(snippet => {
          snippet.installed = newVal.includes(snippet.id);
        });
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
        }
      },
      loadedSnippet(id) {
        s = this.snippets.find(s => s.id === id);
        if (s) {
          s.loaded = true;
        }
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
      remove(snippet){
        this.call('remove', snippet);
      },
      update(snippet){
        this.call('update', snippet);
      }
    },
    computed: {
      filteredSnippets() {
        return this.snippets.filter(snippet => {
          const search = this.search.toLowerCase();
          return snippet.name.toLowerCase().includes(search) || snippet.description.toLowerCase().includes(search);
        });
      }
    },
    mounted() {
      try {
        sketchup.ready();
      } catch (error) {
        console.error(error);        
      }
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
