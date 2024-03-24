var app;
function createVueApp() {
  app = new Vue({
    el: '#app',
    data: {
      snippets: []
    },
    created() {
      this.fetchSnippets();
    },
    methods: {
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
          })
          .catch(error => {
            console.error('There has been a problem with your fetch operation:', error);
          });
      }
    }
  });
}

document.addEventListener('DOMContentLoaded', function () {
  createVueApp();
});

function loadAndProcessZip(url) {
  console.log(`Loading and processing ZIP from ${url}...`);
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
          // Gửi nội dung của mỗi file xuống Ruby
          console.log(`File ${filename} has content:`, content);
          sendToRuby(filename, content);
        });
      });
    })
    .catch(err => {
      console.error('Error loading or processing zip:', err);
    });
}

// Giả sử sendToRuby là hàm bạn sẽ định nghĩa để gửi nội dung xuống Ruby
function sendToRuby(filename, content) {
  // Tại đây bạn có thể sử dụng Web Dialog hoặc HTML Dialog API của SketchUp
  // để gửi nội dung tới Ruby. Ví dụ:
  console.log(`Sending ${filename} to Ruby...`);
  console.log(`Content: ${content}`);
  sketchup.call('loadrb', filename, content)
}

console.log("Rubiny plugin page loaded successfully!");
