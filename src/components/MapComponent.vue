<template>
  <div id="map" class="map-container"></div>
</template>

<script setup>
import { onMounted, watch } from "vue";
import mapboxgl from "mapbox-gl";
import { useQuasar } from "quasar";
import { useSearchStore } from "src/stores/search-store";
import { useMapStore } from "src/stores/map-store";
import { useWeatherStore } from "src/stores/weather-store";

import vertexShader from "src/shaders/vertex.glsl?raw";
import fragmentShader from "src/shaders/fragment.glsl?raw";

import { createProgram, createFullscreenQuad } from "src/utils/shader-helpers";

const $q = useQuasar();
const searchStore = useSearchStore();
const mapStore = useMapStore();
const weatherStore = useWeatherStore();

let map;
const apiKey = import.meta.env.VITE_MAPBOX_API_KEY;
let currentLayerId = null;
let displayedStyle = null;

const atmosphereColor = { r: 0, g: 0, b: 0 };
let mistFactor = 0;
let cloudFactor = 0;
let rainFactor = 0;

const texturePaths = [
  { name: "uAshTexture", path: "./noise-textures/Perlin23-512x512.png" },
  { name: "uCloudTexture", path: "./noise-textures/Milky6-512x512.png" },
  { name: "uSmokeTexture", path: "./noise-textures/SuperPerlin2-512x512.png" },
  { name: "uRainTexture", path: "./noise-textures/Perlin24-512x512.png" },
];

const mapStyles = {
  placeholder: "mapbox://styles/karinmiriam/cml9i2zeb001801s88vlc747z",
  winter: "mapbox://styles/karinmiriam/cml9alr3f002501qzdrwabuer",
  autumn: "mapbox://styles/karinmiriam/cml9fuw9f006c01sj5hqd6ytl",
  spring: "mapbox://styles/karinmiriam/cml9h8dgz003f01r07i9h60bk",
  summer: "mapbox://styles/karinmiriam/cmlrol2w7001m01qo4vvwb0di",
  tropical: "mapbox://styles/karinmiriam/cml9hqmkw000t01s7frzh09k3",
  desert: "mapbox://styles/karinmiriam/cml9hvfca003j01r0d3jjcbkg",
};

function removeLayerIfExists(layerId) {
  if (layerId && map.getLayer(layerId)) map.removeLayer(layerId);
}

function addShaderLayer(layerId, vertexShader, fragmentShader) {
  removeLayerIfExists(currentLayerId);

  let startTime = performance.now();

  map.addLayer({
    id: layerId,
    type: "custom",
    renderingMode: "2d",

    onAdd: function (_, gl) {
      this.textures = [];
      this.textureUniforms = [];
      this.nextTextureUnit = 0;

      this.program = createProgram(gl, vertexShader, fragmentShader);
      if (!this.program) return;

      // Set attributes and uniforms
      this.aPos = gl.getAttribLocation(this.program, "a_pos");

      this.uTime = gl.getUniformLocation(this.program, "uTime");
      this.uResolution = gl.getUniformLocation(this.program, "uResolution");
      this.uWind = gl.getUniformLocation(this.program, "uWind");
      this.uAtmosphereColor = gl.getUniformLocation(this.program, "uAtmosphereColor");
      this.uMistFactor = gl.getUniformLocation(this.program, "uMistFactor");
      this.uCloudFactor = gl.getUniformLocation(this.program, "uCloudFactor");
      this.uRainFactor = gl.getUniformLocation(this.program, "uRainFactor");

      // Set texture uniforms and load textures
      texturePaths.forEach((texturePath) => {
        this.textureUniforms.push(gl.getUniformLocation(this.program, texturePath.name));
        this.addTexture(gl, texturePath.path);
      });

      this.buffer = createFullscreenQuad(gl);
    },

    addTexture(gl, path) {
      const texture = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, texture);

      // 1x1 placeholder
      gl.texImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        1,
        1,
        0,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        new Uint8Array([0, 0, 0, 255]),
      );

      const image = new Image();
      image.src = path;
      image.onload = () => {
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
        gl.generateMipmap(gl.TEXTURE_2D);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      };

      this.textures.push({ texture, unit: this.nextTextureUnit });
      this.nextTextureUnit++;
    },

    render: function (gl, _) {
      if (!this.program) return;

      gl.useProgram(this.program);

      const time = (performance.now() - startTime) * 0.001;
      gl.uniform1f(this.uTime, time);
      gl.uniform2f(this.uResolution, gl.canvas.width, gl.canvas.height);
      gl.uniform1f(this.uWind, weatherStore.windSpeed);
      gl.uniform3f(this.uAtmosphereColor, atmosphereColor.r, atmosphereColor.g, atmosphereColor.b);
      gl.uniform1f(this.uMistFactor, mistFactor);
      gl.uniform1f(this.uCloudFactor, cloudFactor);
      gl.uniform1f(this.uRainFactor, rainFactor);

      this.textures.forEach((t, i) => {
        gl.activeTexture(gl.TEXTURE0 + t.unit);
        gl.bindTexture(gl.TEXTURE_2D, t.texture);
        gl.uniform1i(this.textureUniforms[i], t.unit);
      });

      gl.bindBuffer(gl.ARRAY_BUFFER, this.buffer);
      gl.enableVertexAttribArray(this.aPos);
      gl.vertexAttribPointer(this.aPos, 2, gl.FLOAT, false, 0, 0);

      gl.enable(gl.BLEND);
      gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

      gl.drawArrays(gl.TRIANGLES, 0, 6);

      gl.disableVertexAttribArray(this.aPos);
      gl.bindBuffer(gl.ARRAY_BUFFER, null);

      map.triggerRepaint();
    },

    onRemove: function (_, gl) {
      if (this.buffer) gl.deleteBuffer(this.buffer);

      if (this.program && gl.getProgramParameter(this.program, gl.DELETE_STATUS))
        gl.deleteProgram(this.program);
    },
  });

  currentLayerId = layerId;
}

async function setMapStyle() {
  const data = await weatherStore.fetchWeatherData(mapStore.lng, mapStore.lat);

  if (!data) return;

  let currentStyle;

  if (data.main.temp <= 0) {
    currentStyle = "winter";
  } else if (data.main.temp > 0 && data.main.temp <= 10) {
    currentStyle = "autumn";
  } else if (data.main.temp > 10 && data.main.temp <= 20) {
    currentStyle = "spring";
  } else if (data.main.temp > 20 && data.main.temp <= 30) {
    currentStyle = "summer";
  } else if (data.main.temp > 30 && data.main.temp <= 40) {
    currentStyle = "tropical";
  } else if (data.main.temp > 40) {
    currentStyle = "desert";
  }

  function setShader() {
    weatherStore.setAirTemp(Math.round(data.main.temp));
    weatherStore.setFeelsLike(Math.round(data.main.feels_like));
    weatherStore.setLocation(data.name);
    weatherStore.setWindSpeed(Math.round(data.wind.speed * 3.6));

    let weatherMain = "";
    // console.log(data.weather);
    data.weather.forEach((weather, index) => {
      if (index === 0) weatherMain = weather.main;

      if (weather.main === "Clear") {
        addShaderLayer("shaderLayer", vertexShader, fragmentShader);

        // mistFactor = 0;
        // cloudFactor = 0;
        // rainFactor = 0;
        // removeLayerIfExists(currentLayerId);
      } else {
        if (weather.main === "Mist") {
          atmosphereColor.r = 0.7;
          atmosphereColor.g = 0.7;
          atmosphereColor.b = 0.7;
          mistFactor = 1;
        } else if (weather.main === "Fog") {
          atmosphereColor.r = 0.6;
          atmosphereColor.g = 0.6;
          atmosphereColor.b = 0.6;
          mistFactor = 1;
        } else if (weather.main === "Haze") {
          atmosphereColor.r = 0.38;
          atmosphereColor.g = 0.33;
          atmosphereColor.b = 0.28;
          mistFactor = 1;
        } else if (weather.main === "Dust" || weather.main === "Sand") {
          atmosphereColor.r = 0.66;
          atmosphereColor.g = 0.6;
          atmosphereColor.b = 0.55;
          mistFactor = 1;
        } else if (weather.main === "Smoke") {
          atmosphereColor.r = 0.56;
          atmosphereColor.g = 0.56;
          atmosphereColor.b = 0.57;
        } else if (weather.main === "Ash") {
          atmosphereColor.r = 0.0902;
          atmosphereColor.g = 0.1137;
          atmosphereColor.b = 0.1294;
        } else if (weather.main === "Clouds") {
          if (weather.description.includes("overcast")) {
            cloudFactor = 1;
          } else if (weather.description.includes("broken")) {
            cloudFactor = 0.75;
          } else if (weather.description.includes("scattered")) {
            cloudFactor = 0.5;
          } else {
            cloudFactor = 0.25;
          }
        } else if (weather.main === "Rain") {
          rainFactor = 1;
        } else if (weather.main === "Drizzle") {
          rainFactor = 0.5;
        }

        addShaderLayer("shaderLayer", vertexShader, fragmentShader);
      }
    });

    // weatherMain = "Clouds";
    weatherStore.setWeatherType(weatherMain);

    // console.log(data);
  }

  if (currentStyle !== displayedStyle) {
    map.setStyle(mapStyles[currentStyle]);
    displayedStyle = currentStyle;

    map.on("style.load", () => {
      setShader();
    });
  } else {
    setShader();
  }
}

onMounted(async () => {
  map = new mapboxgl.Map({
    container: "map",
    style: mapStyles.placeholder,
    style: null,
    zoom: mapStore.zoom,
    center: [mapStore.lng, mapStore.lat],
    accessToken: apiKey ?? "",
  });

  await setMapStyle();

  map.on("moveend", async () => {
    mapStore.setCoordinates(map.getCenter().lng, map.getCenter().lat);
    mapStore.setZoom(map.getZoom());

    await setMapStyle();
  });
});

watch(
  () => [searchStore.selectedCoordinates.lng, searchStore.selectedCoordinates.lat],
  ([lng, lat]) => {
    if (lng && lat) {
      mapStore.setCoordinates(lng, lat);
      mapStore.setZoom(14);

      map.flyTo({
        center: [lng, lat],
        zoom: 14,
        essential: true,
      });

      setMapStyle();
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
