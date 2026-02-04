<template>
  <div class="overlay" v-if="showOverlay" :style="overlayStyle"></div>

  <div ref="mapContainer" id="map" class="map-container"></div>

  <PopupComponent v-if="showPopup" :popup="popup" @close="hidePopup" />
  <SuggestionPopup
    v-if="showSuggestionPopup"
    :popupRect="suggestionPopupRect"
    @close="hideSuggestionPopup"
  />
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from "vue";
import mapboxgl from "mapbox-gl";
import { features } from "./data";
import PopupComponent from "./PopupComponent.vue";
import type Popup from "./popup.interface";
import { useQuasar } from "quasar";
import SuggestionPopup from "./SuggestionPopup.vue";
import PopupRect from "./popup-rect.interface";
import { useSearchStore } from "src/stores/search-store";
import gsap from "gsap";

const $q = useQuasar();
const searchStore = useSearchStore();

let map: any;
let marker: any;
let buttonElement;
let buttonMarker: any;
let buttonSize = { w: 140, h: 56 };
let buttonId = "";
const apiKey = process.env.VITE_MAPBOX_API_KEY;
const mapContainer = ref(null);
let hoveredFeatureId: string | null = null;
const x = ref(0);
const y = ref(0);
const showOverlay = ref(false);
const showPopup = ref(false);
const showSuggestionPopup = ref(false);
let isOpeningSuggestionPopup = false;
const showSuggestButton = ref(false);
const suggestionPopupRect = ref({ w: 400, h: 320, x: 0, y: 0, lat: 0, lng: 0 } as PopupRect);
const popup = ref<Popup>({ title: "", attachments: [], folderName: "" });
let isAnimating = false;

const overlayStyle = computed(() => {
  const radius = Math.max(window.innerWidth, window.innerHeight) * 0.5;
  return {
    maskImage: `radial-gradient(circle ${radius}px at ${x.value}px ${y.value}px, transparent 0%, transparent 30%, black 100%)`,
    WebkitMaskImage: `radial-gradient(circle ${radius}px at ${x.value}px ${y.value}px, transparent 0%, transparent 30%, black 100%)`,
  };
});

onMounted(() => {
  window.addEventListener("mousemove", onMouseDown);

  map = new mapboxgl.Map({
    container: "map",
    // purple-cyan-raleway
    style: "mapbox://styles/karinmiriam/cmaqslh9g00r501s90mydcred",
    zoom: 12,
    center: [13.407557, 52.509237],
    accessToken: apiKey ?? "",
  });

  features.forEach((feature) => {
    new mapboxgl.Marker({
      element: createCustomMarker(
        feature.geometry.coordinates[0] ?? 0,
        feature.geometry.coordinates[1] ?? 0,
        "Open",
      ),
    })
      .setLngLat([feature.geometry.coordinates[0], feature.geometry.coordinates[1]])
      .addTo(map);
  });

  map.on("style.load", () => {
    map.addSource("places", {
      type: "geojson",
      data: {
        type: "FeatureCollection",
        features,
      },
    });
  });

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  map.on("contextmenu", (e: any) => {
    showSuggestionPopup.value = false;
    if (marker) marker.remove();

    marker = new mapboxgl.Marker({
      element: createCustomMarker(e.lngLat.lng, e.lngLat.lat, "Suggest"),
    })
      .setLngLat([e.lngLat.lng, e.lngLat.lat])
      .addTo(map);

    suggestionPopupRect.value.lng = e.lngLat.lng;
    suggestionPopupRect.value.lat = e.lngLat.lat;
  });
});

function createLocationId(lng: number, lat: number) {
  return `lng${lng.toString().replace(".", "-")}lat${lat.toString().replace(".", "-")}`;
}

function createCustomMarker(lng: number, lat: number, buttonText: string) {
  const id = createLocationId(lng, lat);
  const markerElement = document.createElement("div");

  markerElement.innerHTML = `
      <div style="display: flex; flex-direction: column; gap: 2px; align-items: center; transform: translateY(-2px); border-radius: 50%; height: 28px; width: 28px">
        <div id="${id}-top" style="width: 10px; height: 10px; border-radius: 5px; background: ${buttonText === "Open" ? "white" : "#0a1657"}"></div>
        <div style="display: flex; gap: 4px">
          <div id="${id}-bottom-left" style="width: 10px; height: 10px; border-radius: 5px; background: ${buttonText === "Open" ? "white" : "#0a1657"}"></div>
          <div id="${id}-bottom-right" style="width: 10px; height: 10px; border-radius: 5px; background: ${buttonText === "Open" ? "white" : "#0a1657"}"></div>
        </div>
      </div>
       `;

  return markerElement;
}

function showButton(lng: number, lat: number, id: string, buttonText: string) {
  if (isAnimating || isOpeningSuggestionPopup || showSuggestionPopup.value || showPopup.value)
    return;

  isAnimating = true;
  buttonId = id;
  if (buttonMarker) buttonMarker.remove();

  setTimeout(() => {
    buttonElement = document.createElement("div");
    buttonElement.innerHTML = `<button id="${id}-button" style="font-family: inherit; font-weight: 700; font-size: 18px; border: 0; width: ${buttonSize.w}px; height: ${buttonSize.h}px; border-radius: 2px; background: ${buttonText === "Open" ? "white" : "#0a1657"}; color: ${buttonText === "Open" ? "#0a1657" : "white"}">${buttonText}</button>`;

    buttonElement.addEventListener("mouseleave", () => {
      hideButton();
    });

    buttonMarker = new mapboxgl.Marker({
      element: buttonElement,
    })
      .setLngLat([lng, lat])
      .addTo(map);

    if (buttonText === "Suggest") {
      suggestionPopupRect.value.x = buttonElement.getBoundingClientRect().left;
      suggestionPopupRect.value.y = buttonElement.getBoundingClientRect().top;
      suggestionPopupRect.value.lng = lng;
      suggestionPopupRect.value.lat = lat;

      buttonElement.addEventListener("mousedown", () => {
        openSuggestionPopup();
        hideButton();
      });
    } else {
      buttonElement.addEventListener("mousedown", () => {
        showOverlay.value = true;
        showPopup.value = true;

        const feature = features.find(
          (f) => f.geometry.coordinates[0] === lng && f.geometry.coordinates[1] === lat,
        );

        if (feature) {
          popup.value = {
            title: feature.properties.description,
            attachments: feature.properties.attachments,
            folderName: feature.properties.folderName,
          };
        }
      });
    }
  }, 150);

  setTimeout(() => {
    isAnimating = false;
  }, 200);

  gsap.to(`#${id}-top`, {
    scaleX: 14,
    scaleY: 5.6,
    borderRadius: 0,
    duration: 0.2,
    force3D: false,
    y: "12px",
    ease: "power2.inOut",
  });
  gsap.to(`#${id}-bottom-left`, {
    scaleX: 14,
    scaleY: 5.6,
    borderRadius: 0,
    duration: 0.2,
    force3D: false,
    x: "7px",
    ease: "power2.inOut",
  });
  gsap.to(`#${id}-bottom-right`, {
    scaleX: 14,
    scaleY: 5.6,
    borderRadius: 0,
    duration: 0.2,
    force3D: false,
    x: "-7px",
    ease: "power2.inOut",
  });

  gsap.set(`#${id}-top`, { opacity: 0, delay: 0.2 });
  gsap.set(`#${id}-bottom-left`, { opacity: 0, delay: 0.2 });
  gsap.set(`#${id}-bottom-right`, { opacity: 0, delay: 0.2 });
}

function hideButton() {
  if (isAnimating) return;

  isAnimating = true;
  if (buttonMarker) buttonMarker.remove();

  setTimeout(() => {
    isAnimating = false;
  }, 300);

  gsap.set(`#${buttonId}-top`, { opacity: 1 });
  gsap.set(`#${buttonId}-bottom-left`, { opacity: 1 });
  gsap.set(`#${buttonId}-bottom-right`, { opacity: 1 });

  gsap.to(`#${buttonId}-top`, {
    scale: 1,
    borderRadius: "5px",
    duration: 0.3,
    force3D: false,
    y: "0",
    ease: "power2.inOut",
  });
  gsap.to(`#${buttonId}-bottom-left`, {
    scale: 1,
    borderRadius: "5px",
    duration: 0.3,
    force3D: false,
    x: "0",
    ease: "power2.inOut",
  });
  gsap.to(`#${buttonId}-bottom-right`, {
    scale: 1,
    borderRadius: "5px",
    duration: 0.3,
    force3D: false,
    x: "0",
    ease: "power2.inOut",
  });
}

function openSuggestionPopup() {
  isOpeningSuggestionPopup = true;
  let popupX = 0;
  let popupY = 0;

  if ($q.screen.gt.sm) {
    // popup coordinates for md & larger screens
    popupX = Math.min(
      window.innerWidth - suggestionPopupRect.value.w,
      suggestionPopupRect.value.x + 100,
    );
    popupY = Math.min(
      window.innerHeight - suggestionPopupRect.value.h,
      suggestionPopupRect.value.y,
    );
  } else {
    // popup coordinates for xs & sm screens
    popupX = 0;
    popupY = window.innerHeight * 0.3;
  }
  suggestionPopupRect.value.x = popupX;
  suggestionPopupRect.value.y = popupY;

  setTimeout(() => {
    showSuggestionPopup.value = true;
    isOpeningSuggestionPopup = false;
  }, 100);
}

function hideSuggestionPopup() {
  showSuggestionPopup.value = false;
}

function hideSuggestButton() {
  showSuggestButton.value = false;
}

function hidePopup() {
  showOverlay.value = false;
  showPopup.value = false;
  hoveredFeatureId = null;
}

onUnmounted(() => {
  window.removeEventListener("mousedown", onMouseDown);
});

function onMouseDown(e: MouseEvent) {
  if (!showOverlay.value) return;

  x.value = e.clientX;
  y.value = e.clientY;
}

watch(
  () => [searchStore.selectedCoordinates.lng, searchStore.selectedCoordinates.lat],
  ([lng, lat]) => {
    if (lng && lat) {
      showSuggestButton.value = false;
      if (marker) marker.remove();

      map.flyTo({
        center: [lng, lat],
        zoom: 14,
        essential: true,
      });

      marker = new mapboxgl.Marker({
        element: createCustomMarker(lng, lat, "Suggest"),
      })
        .setLngLat([lng, lat])
        .addTo(map);
    }
  },
);
</script>

<style scoped lang="scss">
.overlay {
  position: absolute;
  inset: 0;
  background: rgba(255, 255, 255, 0.67);
  pointer-events: none;
  z-index: 2000;
}

:deep(a) {
  color: $font-color;
  text-decoration: none;
  font-size: 8px;
}

:deep(.mapboxgl-marker) {
  pointer-events: none;
}

.map-container {
  width: 100%;
  height: 100vh;
  height: 100dvh;
}
</style>
