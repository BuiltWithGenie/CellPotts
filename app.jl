using GenieFramework
@genietools
using CellularPotts, PlotlyBase

Stipple.Layout.add_script("https://cdn.tailwindcss.com")
@app begin
    @in S = 100
    @in N = 1
    @in adhesion = 20
    @in volume = 100
    @in volumePenalty = 5
    @in migration = 50
    @in iterations = 100
    @out t = 1
    @out N_cells = 1
    @in division = true
    @in interval = 40
    @in animate = false
    @out nodeIDs = [[],[]]
    @out trace = [heatmap()]
    @out layout = PlotlyBase.Layout(height=650,width=650)
    @onbutton animate begin
        penalties = [
                     AdhesionPenalty([0 adhesion;
                                      adhesion adhesion]),
                     VolumePenalty([volumePenalty]),
                     MigrationPenalty(S, [migration], (S,S))
                    ]
        initialCellState = CellState(:Epithelial, volume, N)
        space = CellSpace(S,S; periodic=true, diagonal=true)
        cpm = CellPotts(space, initialCellState, penalties)
        cells = collect(1:N)
        for t in 1:iterations-1
            ModelStep!(cpm)
            sleep(0.1)
            x0 = []
            y0 = []
            x1 = []
            y1 = []
            if t%interval == 0 && division
                for c in 1:N_cells
                    CellDivision!(cpm, c)
                end
                N_cells = cpm.state.cellIDs[end]
                push!(cells, N_cells)
            end
            for i in 2:S
                for j in 2:S
                    if cpm.space.nodeIDs[i,j] != cpm.space.nodeIDs[i,j-1]
                        push!(x0, i-1.5)
                        push!(y0, j-1.5)
                        push!(x1, i-0.5)
                        push!(y1, j-1.5)
                    end
                    if cpm.space.nodeIDs[i,j] != cpm.space.nodeIDs[i-1,j]
                        push!(x0, i-1.5)
                        push!(y0, j-1.5)
                        push!(x1, i-1.5)
                        push!(y1, j-0.5)
                    end
                end
            end
            shapes = PlotlyBase.line(x0,x1,y0,y1; xref="x", yref="y")
            #= layout = PlotlyBase.Layout(height=500,width=500,shapes=shapes) =#
            trace = [heatmap(z=cpm.space.nodeIDs', colorscale="picnic", showscale="false")]
            nodeIDs = [vec(row) for row in eachrow( cpm.space.nodeIDs')]
        end
    end
end

ui()=[
      h1("Cellular potts model"),
      cell( class="flex", [
                           cell(class="w-1/2", [
                                                GenieFramework.plot(:trace, layout=:layout),
                                                btn("Animate", @click(:animate), color="primary"),
                                                btn("Stop", @click("animate = false"), color="primary")
                                               ]),
                           cell(class="w-1/2 pl-10 pt-19", [
                                                            card(class="p-10", [
                                                                                h6("Space parameters"),
                                                                                badge("Cell volume (px)"),
                                                                                slider(100:50:500, :volume, var"label-always"=true),
                                                                                badge("Number of cells"),
                                                                                slider(1:1:10,:N, var"label-always"=true),
                                                                                badge("Space size"),
                                                                                slider(100:50:250,:S, var"label-always"=true),
                                                                                badge("Iterations"),
                                                                                slider(1:1:1000,:iterations, var"label-always"=true),
                                                                                badge("Division interval"),
                                                                                row([
                                                                                     radio("20", :interval, val=20),radio("30", :interval, val=30),radio("40", :interval, val=40),radio("50", :interval, val=50)
                                                                                     ,radio(class="ml-20","No division", :interval, val=20000),]),
                                                                                h6("Cell parameters"),
                                                                                badge("Adhesion penalty"),
                                                                                slider(0:5:50, :adhesion, var"label-always"=true),
                                                                                badge("Volume penalty"),
                                                                                slider(0:5:50, :volumePenalty, var"label-always"=true),
                                                                                badge("Migration speed"),
                                                                                slider(0:50:500, :migration, var"label-always"=true),
                                                                               ]),
                                                           ])
                          ])
                          ]
                          @page("/","app.jl.html")
