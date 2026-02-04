<template>
  <div v-if="images.length" class="img-container">
    <div v-for="(image, index) in images" :key="image" class="img-wrapper">
      <img :src="`/images/${folderName}/${image}`" :class="`image-${index}`" />
    </div>
    <div class="title-wrapper">
      <h2>{{ title }}</h2>
    </div>
  </div>
</template>

<script setup lang="ts">
import { PropType, onMounted, onUnmounted } from "vue";
import gsap from "gsap";
import { useQuasar } from "quasar";

const $q = useQuasar();

const props = defineProps({
  images: {
    type: Array as PropType<string[]>,
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  folderName: {
    type: String,
    required: true,
  },
});

let previousIndex = 0;
let currentIndex = 1;
let isAnimating = false;

onMounted(() => {
  for (let i = 1; i < props.images.length; i++) gsap.set(`.image-${i}`, { opacity: 0 });

  if (props.images.length > 1) {
    isAnimating = true;
    $q.screen.gt.sm ? animateDesktop() : animateMobile();
  }
});

onUnmounted(() => {
  isAnimating = false;
});

function animateMobile() {
  if (!isAnimating) return;

  gsap.to(`.image-${currentIndex}`, {
    opacity: 1,
    duration: 3,
    delay: 2,
  });

  gsap.to(`.image-${previousIndex}`, {
    opacity: 0,
    duration: 3,
    delay: 2,
    onComplete: () => {
      previousIndex = currentIndex;

      if (currentIndex === props.images.length - 1) {
        currentIndex = 0;
      } else {
        currentIndex++;
      }
      animateMobile();
    },
  });
}

function animateDesktop() {
  if (!isAnimating) return;

  gsap.to(`.image-${currentIndex}`, {
    opacity: 1,
    duration: 3,
    delay: 2,
  });

  gsap.to(`.image-${previousIndex}`, {
    opacity: 0,
    duration: 3,
    delay: 2,
    onComplete: () => {
      previousIndex = currentIndex;

      if (currentIndex === props.images.length - 1) {
        currentIndex = 0;
      } else {
        currentIndex++;
      }
      animateDesktop();
    },
  });
}
</script>

<style scoped lang="scss">
// img {
//   filter: grayscale(100%) sepia(33%) hue-rotate(200deg) saturate(160%);
// }

.img-container {
  position: relative;
  width: 100%;
  height: 100%;
}

.img-wrapper {
  position: absolute;
  width: 100%;
  height: calc(100% - 40px);
  overflow: hidden;
  border-radius: 2px;

  img {
    width: 100%;
    object-fit: cover;
  }
}

.title-wrapper {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: flex-end;
}
</style>
