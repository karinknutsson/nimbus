import type Feature from "./feature.interface";

function createImageArray(count: number) {
  return Array.from({ length: count }, (_, i) => `${i}.jpg`);
}

export const features: Feature[] = [
  {
    type: "Feature",
    properties: {
      description: "Treptower Park",
      attachments: createImageArray(8),
      folderName: "treptower-park",
    },
    geometry: {
      type: "Point",
      coordinates: [13.469367, 52.487252],
    },
  },
  {
    type: "Feature",
    properties: {
      description: "Grunewald",
      attachments: [],
      folderName: "grunewald",
    },
    geometry: {
      type: "Point",
      coordinates: [13.211403, 52.487731],
    },
  },
  {
    type: "Feature",
    properties: {
      description: "Tiergarten",
      attachments: [],
      folderName: "tiergarten",
    },
    geometry: {
      type: "Point",
      coordinates: [13.340973, 52.512238],
    },
  },
  {
    type: "Feature",
    properties: {
      description: "Volkspark Prenzlauer Berg",
      attachments: createImageArray(4),
      folderName: "volkspark-prenzlauer-berg",
    },
    geometry: {
      type: "Point",
      coordinates: [13.464988, 52.535379],
    },
  },
];
