Campaings.Views.Campaings ||= {}

class Campaings.Views.Campaings.NewView extends Backbone.View
  template: JST["backbone/templates/campaings/new"]
  templateCountrie: JST["backbone/templates/campaings/countrie"]
  templateLanguage: JST["backbone/templates/campaings/language"]

  events:
    "submit #new-campaing"   : "save"
    "click  #add_countrie"   : "addCountrie"
    "click  .remove_countrie": "removeCountrie"
    "click  .add_language"   : "addLanguage"
    "click  .remove_language": "removeLanguage"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  addLanguage: (e) ->
    self = $(e.currentTarget).parent().find(".languages")
    self.append(@templateLanguage)

  removeLanguage: (e) ->
    $(e.currentTarget).parent().remove()

  addCountrie: ->
    $(@el).find(".countries").append(@templateCountrie)

  removeCountrie: (e) ->
    $(e.currentTarget).parent().remove()

  getCountries: ->
    result = {}
    countries = $(@el).find("div.countrie")
    for countrie in countries
      countrieName = $(countrie).find("input.countrie").val()
      if (!result[countrieName]) 
        result[countrieName] = []
      languages = $(countrie).find("input.language")
      for lang in languages
        result[countrieName].push(lang.value)
    return JSON.stringify(result)

  getFormParams: ->
    result = {
      name: $(@el).find("#name").val(),
      start_at: new Date( $(@el).find("#start_at").val() ),
      end_at: new Date( $(@el).find("#end_at").val() ),
      countries: @getCountries()
    }
    return result

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")
    @model.set(@getFormParams())
    @collection.create(@model.toJSON(),
      success: (campaing) =>
        @model = campaing
        window.location.hash = "/#{@model.id}"

      error: (campaing, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    $(@el).find(".datepicker").datepicker();
    return this
