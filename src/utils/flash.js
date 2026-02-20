// flash.js
import gsap from "gsap";

export function flash() {
  let delay = 0;

  gsap.to("#lightning", {
    opacity: 0.8,
    duration: 0.06,
    delay,
    ease: "power4.out",
  });

  delay += 0.07;

  gsap.to("#lightning", {
    opacity: 0,
    duration: 0.06,
    delay,
    ease: "power4.in",
  });

  delay += 1.06;

  gsap.to("#lightning", {
    opacity: 0.8,
    duration: 0.06,
    delay,
    ease: "power4.out",
  });

  delay += 0.07;

  gsap.to("#lightning", {
    opacity: 0,
    duration: 0.06,
    delay,
    ease: "power4.in",
  });

  delay += 0.36;

  gsap.to("#lightning", {
    opacity: 0.8,
    duration: 0.06,
    delay,
    ease: "power4.out",
  });

  delay += 0.18;

  gsap.to("#lightning", {
    opacity: 0,
    duration: 0.06,
    delay,
    ease: "power4.in",
  });

  delay += 2.0;

  gsap.to("#lightning", {
    opacity: 0.6,
    duration: 0.06,
    delay,
    ease: "power4.out",
  });

  delay += 0.07;

  gsap.to("#lightning", {
    opacity: 0,
    duration: 0.06,
    delay,
    ease: "power4.in",
  });
}
