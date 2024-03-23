console.log("Rubiny plugin page loaded successfully!");

// Vue app
const app = new Vue({
  el: "#app",
  data: {
    message: "Hello Vue!",
  },
  methods: {
    updateMessage() {
      this.message = "Hello World!";
    },
  },

  // Lifecycle hooks
  created() {
    console.log("Vue app created!");
  },

  // Mounted
  mounted() {
    sketchup.ready();
  },
});