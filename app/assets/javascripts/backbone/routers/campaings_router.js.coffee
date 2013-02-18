class Campaings.Routers.CampaingsRouter extends Backbone.Router
  initialize: (options) ->
    @campaings = new Campaings.Collections.CampaingsCollection()
    @campaings.reset options.campaings

  routes:
    "new"      : "newCampaing"
    "index"    : "index"
    ":id"      : "show"
    ".*"        : "index"

  newCampaing: ->
    @view = new Campaings.Views.Campaings.NewView(collection: @campaings)
    $("#campaings").html(@view.render().el)

  index: ->
    @view = new Campaings.Views.Campaings.IndexView(campaings: @campaings)
    $("#campaings").html(@view.render().el)

  show: (id) ->
    campaing = @campaings.get(id)

    @view = new Campaings.Views.Campaings.ShowView(model: campaing)
    $("#campaings").html(@view.render().el)
