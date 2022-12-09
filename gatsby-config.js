module.exports = {
  siteMetadata: {
    siteUrl: `https://www.yourdomain.tld`,
  },
  plugins: [
    `gatsby-plugin-react-helmet`,

    {
      resolve: `gatsby-plugin-manifest`,
      options: {
        icon: "src/images/favicon_256x256.png", // This path is relative to the root of the site.
      },
    },
  ]
}
