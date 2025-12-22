// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')
const { VueLoaderPlugin } = require('vue-loader')

const webpackConfig = generateWebpackConfig()

// Add Vue loader
webpackConfig.module.rules.push({
  test: /\.vue$/,
  loader: 'vue-loader'
})

webpackConfig.plugins.push(new VueLoaderPlugin())

// Resolve Vue
webpackConfig.resolve.alias = {
  ...webpackConfig.resolve.alias,
  'vue': 'vue/dist/vue.esm-bundler.js'
}

module.exports = webpackConfig
