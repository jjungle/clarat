# Additional custom Handlebars helpers.
# Usable with `{{methodname attribute optionname=optionvalue }}`
Handlebars.registerHelper
  # Translations in Handlebars. Make sure to provide a scope that contains at
  # least 'js'
  i18n: (string, options) ->
    I18n.t string, options.hash if string

  # Logic comparator. This goes against Handlebars conventions so use with care.
  ifDiffering: (string, options) ->
    if string is options.hash.from
      options.inverse this
    else
      options.fn this

  debug: (options) ->
    console.log 'Debugging Handlebars:'
    console.log this
    console.log options
