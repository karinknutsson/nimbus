export function areCoordinates(input: string) {
  const coordRegex = /^\s*(-?\d+(\.\d+)?)[,\s]+(-?\d+(\.\d+)?)\s*$/;
  const match = input.match(coordRegex);
  if (match) {
    return true;
  } else {
    return false;
  }
}

export function isCoordinate(input: string) {
  const coordRegex = /^\s*(-?\d+(\.\d+)?)/;
  const match = input.match(coordRegex);
  if (match) {
    return true;
  } else {
    return false;
  }
}
