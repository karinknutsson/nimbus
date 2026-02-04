import PrimeVue from "primevue/config";
import "primeicons/primeicons.css";
// import Aura from "@primevue/themes/aura";

export default ({ app }) => {
  app.use(PrimeVue, {
    theme: {
      //   preset: Aura,
      options: {
        prefix: "p",
        darkModeSelector: false,
        cssLayer: false,
      },
    },
  });
};
