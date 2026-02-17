<template>
  <div class="navbar-container">
    <div class="search-wrapper">
      <SearchBar />
    </div>
    <div></div>

    <div class="temp-wrapper">
      <div class="feels-like-temp-wrapper">{{ weatherStore.feelsLikeTemp + "°" }}</div>
      <div class="weather-description-wrapper">
        <div>{{ weatherStore.feelsLikeDescription }}</div>
        <div>{{ "Air temp " + weatherStore.airTemp + "°" }}</div>
        <div>{{ weatherStore.windDescription }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useQuasar } from "quasar";
import SearchBar from "./SearchBar.vue";
import gsap from "gsap";
import { useSearchStore } from "src/stores/search-store";
import { watch } from "vue";
import { useWeatherStore } from "../stores/weather-store";

const weatherStore = useWeatherStore();
const searchStore = useSearchStore();
const $q = useQuasar();

function handleOpenSearch() {
  gsap.to(".nav-btn", {
    duration: 0.2,
    opacity: 0,
    ease: "power2.out",
  });
}

function handleCloseSearch() {
  gsap.to(".nav-btn", {
    duration: 0.2,
    opacity: 1,
    ease: "power2.out",
    delay: 0.3,
  });
}

watch(
  () => $q.screen.gt.sm,
  (isDesktop) => {
    if (isDesktop) {
      handleCloseSearch();
    } else if (searchStore.isSearchOpen) {
      handleOpenSearch();
    }
  },
);

watch(
  () => searchStore.isSearchOpen,
  (isOpen) => {
    if ($q.screen.gt.sm) return;

    if (isOpen) {
      handleOpenSearch();
    } else {
      handleCloseSearch();
    }
  },
);
</script>

<style scoped lang="scss">
button.nav-btn {
  border: 0;
  color: $deep-blue;
  background: rgba(255, 255, 255, 0.7);
  box-shadow: 0 2px 24px 0 rgba(83, 15, 148, 0.3);
  border-radius: 2px;
  pointer-events: auto;
  display: flex;
  align-items: center;
  justify-content: center;
}

button.desktop {
  font-size: 16px;
  font-weight: 700;
  text-transform: uppercase;
  padding: 0 32px;
  width: 140px;
  height: 56px;
}

button.mobile {
  width: 44px;
  height: 44px;

  i {
    font-size: 20px;
  }
}

.close-wrapper {
  width: 100%;
  display: flex;
  justify-content: flex-end;
  margin: 6px 0 12px 0;
  // background: magenta;
}

.navbar-container {
  z-index: 20;
  position: absolute;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100px;
  padding: 0 4vw;
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  align-items: center;
  pointer-events: none;
}

.temp-wrapper {
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.feels-like-temp-wrapper {
  font-size: 3rem;
  font-weight: 800;
}

.weather-description-wrapper {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 14px;
  font-weight: 700;
}

.search-wrapper {
  justify-self: start;
}

.close-button {
  pointer-events: auto;
}
</style>
