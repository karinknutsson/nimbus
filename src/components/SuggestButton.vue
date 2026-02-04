<template>
  <div class="button-wrapper" :style="{ top: y + 'px', left: x + 'px' }">
    <button>Suggest location</button>
  </div>
</template>

<script setup lang="ts">
const props = defineProps({
  x: {
    type: Number,
    required: true,
  },
  y: {
    type: Number,
    required: true,
  },
});
</script>

<style scoped lang="scss">
button {
  color: $deep-blue;
  border: 0;
  font-weight: 700;
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.7);
  box-shadow: 0 2px 24px 0 rgba(83, 15, 148, 0.3);
  border-radius: 2px;
}

.button-wrapper {
  position: absolute;
  z-index: 10000;
}
</style>
