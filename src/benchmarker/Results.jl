##############
#  Results   #
##############

struct Results
  samples::Int
  average_time::Float64
  std_dev::Float64
  min_time::Float64
  max_time::Float64
  timings::Array{Float64, 1}
end

function Results(n::Int, timings::Array{Float64, 1})
  samples = n
  average_time = mean(timings)
  std_dev = stdm(timings, average_time)
  min_time = minimum(timings)
  max_time = maximum(timings)

  return Results(samples, average_time, std_dev, min_time, max_time, timings)
end

function Base.show(io::IO, r::Results)
  println("Benchmarking results")
  println("Function repeated: $(r.samples) times")
  println("Average: $(r.average_time)")
  println("Standard deviation: $(round(r.std_dev, digits=3))")
  println("Best: $(r.min_time) $(round(100 * (r.min_time - r.average_time) / r.average_time, digits=3))%")
  println("Worst: $(r.max_time) $(round(100 * (r.max_time - r.average_time) / r.average_time, digits=3))%")
  println("Timings: $(r.timings)")
end
