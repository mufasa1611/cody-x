import { ComponentProps } from "solid-js"

export const Mark = (props: { class?: string }) => {
  return (
    <svg
      data-component="logo-mark"
      classList={{ [props.class ?? ""]: !!props.class }}
      viewBox="25 30 110 115"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <linearGradient id="mk-grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="var(--icon-strong-base)" stop-opacity="1" />
          <stop offset="100%" stop-color="var(--icon-weak-base)" stop-opacity="1" />
        </linearGradient>
      </defs>
      {/* Ears */}
      <circle cx="50" cy="55" r="18" fill="url(#mk-grad)" />
      <circle cx="110" cy="55" r="18" fill="url(#mk-grad)" />
      {/* Head */}
      <circle cx="80" cy="90" r="45" fill="url(#mk-grad)" />
    </svg>
  )
}

export const Splash = (props: Pick<ComponentProps<"svg">, "ref" | "class">) => {
  return (
    <svg
      ref={props.ref}
      data-component="logo-splash"
      classList={{ [props.class ?? ""]: !!props.class }}
      viewBox="20 30 120 155"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <linearGradient id="sp-grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="var(--icon-strong-base)" stop-opacity="1" />
          <stop offset="50%" stop-color="var(--icon-base)" stop-opacity="1" />
          <stop offset="100%" stop-color="var(--icon-weak-base)" stop-opacity="1" />
        </linearGradient>
      </defs>
      {/* Ears */}
      <circle cx="50" cy="55" r="18" fill="url(#sp-grad)" />
      <circle cx="110" cy="55" r="18" fill="url(#sp-grad)" />
      {/* Inner ears */}
      <circle cx="50" cy="55" r="10" fill="var(--icon-base)" />
      <circle cx="110" cy="55" r="10" fill="var(--icon-base)" />
      {/* Head */}
      <circle cx="80" cy="90" r="45" fill="url(#sp-grad)" />
      {/* Eyes */}
      <ellipse cx="65" cy="85" rx="6" ry="7" fill="var(--icon-strong-base)" />
      <ellipse cx="95" cy="85" rx="6" ry="7" fill="var(--icon-strong-base)" />
      {/* Eye highlights */}
      <circle cx="67" cy="82" r="2" fill="var(--icon-invert-base)" />
      <circle cx="97" cy="82" r="2" fill="var(--icon-invert-base)" />
      {/* Nose */}
      <ellipse cx="80" cy="98" rx="8" ry="5" fill="var(--icon-strong-base)" />
      {/* Mouth */}
      <path d="M72 106 Q80 115 88 106" stroke="var(--icon-strong-base)" stroke-width="2" fill="none" stroke-linecap="round" />
      {/* Body */}
      <ellipse cx="80" cy="145" rx="40" ry="30" fill="url(#sp-grad)" />
      {/* Paw prints */}
      <circle cx="52" cy="160" r="6" fill="var(--icon-base)" opacity="0.7" />
      <circle cx="108" cy="160" r="6" fill="var(--icon-base)" opacity="0.7" />
    </svg>
  )
}

export const Logo = (props: { class?: string }) => {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 500 200"
      fill="none"
      classList={{ [props.class ?? ""]: !!props.class }}
    >
      <defs>
        <linearGradient id="lg-grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="var(--icon-strong-base)" stop-opacity="1" />
          <stop offset="50%" stop-color="var(--icon-base)" stop-opacity="1" />
          <stop offset="100%" stop-color="var(--icon-weak-base)" stop-opacity="1" />
        </linearGradient>
      </defs>
      {/* Bear head */}
      <circle cx="50" cy="55" r="18" fill="url(#lg-grad)" />
      <circle cx="110" cy="55" r="18" fill="url(#lg-grad)" />
      <circle cx="50" cy="55" r="10" fill="var(--icon-base)" />
      <circle cx="110" cy="55" r="10" fill="var(--icon-base)" />
      <circle cx="80" cy="90" r="45" fill="url(#lg-grad)" />
      {/* Face */}
      <ellipse cx="65" cy="85" rx="6" ry="7" fill="var(--icon-strong-base)" />
      <ellipse cx="95" cy="85" rx="6" ry="7" fill="var(--icon-strong-base)" />
      <circle cx="67" cy="82" r="2" fill="var(--icon-invert-base)" />
      <circle cx="97" cy="82" r="2" fill="var(--icon-invert-base)" />
      <ellipse cx="80" cy="98" rx="8" ry="5" fill="var(--icon-strong-base)" />
      <path d="M72 106 Q80 115 88 106" stroke="var(--icon-strong-base)" stroke-width="2" fill="none" stroke-linecap="round" />
      {/* Body */}
      <ellipse cx="80" cy="145" rx="40" ry="30" fill="url(#lg-grad)" />
      {/* Paw prints */}
      <circle cx="52" cy="160" r="6" fill="var(--icon-base)" opacity="0.7" />
      <circle cx="108" cy="160" r="6" fill="var(--icon-base)" opacity="0.7" />
      {/* Text */}
      <text x="155" y="85" font-family="'Segoe UI', Arial, Helvetica, sans-serif" font-size="52" font-weight="bold" fill="url(#lg-grad)">
        Cody
      </text>
      <text x="155" y="135" font-family="'Segoe UI', Arial, Helvetica, sans-serif" font-size="32" font-weight="600" fill="var(--icon-strong-base)" letter-spacing="3">
        PRO
      </text>
      <text x="155" y="165" font-family="'Segoe UI', Arial, Helvetica, sans-serif" font-size="14" fill="var(--icon-strong-base)">
        Agent build by M.Farid @ Mufasa
      </text>
      {/* Decorative */}
      <text x="420" y="90" font-family="'Courier New', monospace" font-size="40" fill="var(--icon-weak-base)" opacity="0.5">
        &lt;/&gt;
      </text>
      <circle cx="460" cy="130" r="3" fill="var(--icon-weak-base)" opacity="0.4" />
      <circle cx="470" cy="140" r="2" fill="var(--icon-weak-base)" opacity="0.3" />
      <circle cx="450" cy="140" r="2" fill="var(--icon-weak-base)" opacity="0.3" />
    </svg>
  )
}
