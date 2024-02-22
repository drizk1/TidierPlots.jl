function draw_ggplot(plot::GGPlot)
    
    optional_aes = Dict("color" => "color",
                        "colour" => "color",
                        "shape" => "marker",
                        "size" => "markersize",
                        "stroke" => "strokewidth",
                        "strokecolor" => "strokecolor",
                        "strokecolour" => "strokecolor",
                        "linetype" => "linestyle",
                        "linewidth" => "linewidth",
                        "glow" => "glowwidth",
                        "glowcolor" => "glowcolor",
                        "glowcolour" => "glowcolor",
                        "alpha" => "alpha",
                        "stack" => "stack",
                        "dodge" => "dodge",
                        "errorbar_direction" => "direction",
                        "text" => "text",
                        "label" => "text",
                        "row" => "row",
                        "col" => "col", 
                        "layout" => "layout", 
                        "direction" => "direction", 
                        "group" => "group")

    plot_list = Makie.PlotSpec[]

    for geom in plot.geoms
        # use the dataframe specified in the geom if present, otherwise default to the ggplot one
        plot_data = isnothing(geom.data) ? plot.data : geom.data

        # inherit any aes specified at the ggplot level
        aes_dict = merge(plot.default_aes, geom.aes)

        # check to make sure all required aesthetics are available
        check_aes(geom.required_aes, aes_dict, geom.args["geom_name"]) 
        
        # make a Tuple that contains the columns from the data in their required order to pass to PlotSpec
        args = Tuple([plot_data[!, aes_dict[req_aes]] for req_aes in geom.required_aes])
        
        # make a master list of all possible accepted optional aesthetics and args
        optional_visual_args = merge(optional_aes, geom.special_aes)
        
        # which ones were given as aes?
        optional_aes_given = intersect(
            keys(geom.aes),
            keys(optional_visual_args)
        )

        visual_optional_aes = Dict(Symbol(optional_visual_args[a]) => plot_data[!, aes_dict[a]] for a in optional_aes_given)

        # which ones were given as arguments? 
        args_given = intersect(
            keys(geom.args),
            keys(optional_visual_args)
        )
        
        # make a Dict that has the kwargs
        visual_args = Dict(Symbol(optional_visual_args[a]) => args_dict[a] for a in args_given)

        kwargs = (;merge(visual_args, visual_optional_aes)...)

        push!(plot_list, Makie.PlotSpec(geom.visual, args...; kwargs...))
    end

    Makie.plot(
        Makie.SpecApi.GridLayout(
            Makie.SpecApi.Axis(
                plots = plot_list
            )
        )
    )
    
end