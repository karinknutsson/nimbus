<template>
  <q-page class="row">
    <NavBar />

    <div class="col-xs-12">
      <MapComponent />
    </div>
  </q-page>
</template>

<script setup lang="ts">
import { ref } from "vue";
import MapComponent from "src/components/MapComponent.vue";
import NavBar from "src/components/NavBar.vue";
</script>

<style scoped lang="scss"></style>
