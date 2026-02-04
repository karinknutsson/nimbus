<template>
  <div>
    <div ref="popupRef" v-if="popup" class="popup-wrapper flex-center">
      <div class="popup-container">
        <button class="close-button flex-center" @click="emit('close')">
          <i class="pi pi-times icon"></i></button
        ><ImageFader
          :images="popup.attachments"
          :title="popup.title"
          :folder-name="popup.folderName"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { PropType, ref } from "vue";
import type Popup from "./popup.interface";
import ImageFader from "./ImageFader.vue";
import { useQuasar } from "quasar";
import { onClickOutside } from "@vueuse/core";

const $q = useQuasar();

defineProps({
  popup: {
    type: Object as PropType<Popup>,
    required: true,
  },
});

const emit = defineEmits(["close"]);

const popupRef = ref();

onClickOutside(popupRef, () => {
  emit("close");
});
</script>

<style scoped lang="scss">
.popup-wrapper {
  position: absolute;
  left: 0;
  top: 12vh;
  width: 100vw;
  pointer-events: none;
}

.popup-container {
  background: rgba(255, 255, 255, 0.3);
  z-index: 50000;
  padding: 8px 16px 32px 16px;
  box-shadow: 0 2px 24px 0 rgba(83, 15, 148, 0.3);
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: flex-start;
  width: 100vw;
  max-width: 800px;
  aspect-ratio: 2 / 1.66;
  border-radius: 2px;
  pointer-events: auto;
}
</style>
