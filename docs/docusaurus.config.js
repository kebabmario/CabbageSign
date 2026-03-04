// @ts-check
import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'CabbageSign',
  tagline: 'The SwiftUI Sideloading Template',
  favicon: '/icon.png',

  future: {
    v4: true,
  },

  url: 'https://kebabmario.github.io',
  baseUrl: '/',

  organizationName: 'kebabmario',
  projectName: 'CabbageSign',

  onBrokenLinks: 'throw',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  // Serve images from the repo-root ./assets/ folder at /icon.png, /P1.jpeg, etc.
  staticDirectories: ['static', '../assets'],

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/kebabmario/CabbageSign/tree/main/docs/',
          routeBasePath: 'docs',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'CabbageSign',
        logo: {
          alt: 'CabbageSign icon',
          src: '/icon.png',
          style: {borderRadius: '7px'},
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'mainSidebar',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://github.com/kebabmario/CabbageSign',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {label: 'Introduction', to: '/docs/intro'},
              {label: 'Get Started', to: '/docs/get-started'},
              {label: 'FAQ', to: '/docs/faq'},
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/kebabmario/CabbageSign',
              },
              {
                label: 'Fork on GitHub',
                href: 'https://github.com/kebabmario/CabbageSign/fork',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} CabbageSign. Built with Docusaurus.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['swift', 'bash'],
      },
    }),
};

export default config;
