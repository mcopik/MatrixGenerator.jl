using .Shape
using .Properties

function define_spd(functions, generic_functions)

  functions[ Set([Properties.SPD]) ] =
    (size, shape, props) -> spd(size..., shape, props, false)

  functions[ Set([Properties.SPD, Properties.Positive]) ] =
    (size, shape, props) -> spd(size..., shape, props, true)

  generic_functions[Properties.SPD] =
    (shape, val_types, props) -> spd(shape, val_types, props)
end

function spd(packed_shape::Tuple{T, Shape.Band, Bool, Int, Int}, properties, valTypes) where T

  special_shape, shape, symmetric, rows, cols = packed_shape
  if (special_shape == Shape.General || special_shape == Shape.Symmetric) &&
    (shape.upper_bandwidth + 1 != cols || shape.lower_bandwidth + 1 != rows)
    throw(ErrorException("Banded SPD not supported!"))
  end
  if valTypes == negative
    throw(ErrorException("SPD cannot have all negative values!"))
  end
  mat = spd(rows, cols, special_shape, properties, valTypes == positive)
  # apply band to remove unnecessary elems
  return apply_band(special_shape, shape, rows, cols, mat)
end

function spd(rows, cols, shape::Shape.General, properties, positive::Bool)

  if rows != cols
    throw(ErrorException("A not square matrix cannot be symmetric positive definite!"))
  else
    return spd(rows, cols, Shape.Symmetric(), properties, positive).data
  end

end

"""
  Generate an SPD matrix by using the property that for each invertible matrix A,
  A' * A is SPD. A randomized matrix may be singular, although this case is
  extremely unlikely. To avoid additional check for determinant, we use the
  Cholesky factorization and create a triangular matrix.
  Triangular matrices are non-singular iff all diagonal entries are non-zero.
  The proof is trivial - express matrix determinant with Laplace expansion, starting
  from a first row.
"""
function spd(rows, cols, shape::Shape.Symmetric, properties, _positive::Bool)

  if rows != cols
    throw(ErrorException("Non-square matrix passed to a symmetric generator!"))
  end

  if _positive
    mat = random(rows, cols, Shape.UpperTriangular(),
      Set([Properties.Random]), positive)
  else
    mat = random(rows, cols, Shape.UpperTriangular(),
      Set([Properties.Random(-1, 1)]), none)
  end
  # Avoid very low determinant
  #@printf("%f %f %f %f\n", mat(1, 1), mat(1, 2), mat(2, 1), mat(2,2))
  mat = mat + Matrix{Float64}(I, rows, rows) * rows
  return Symmetric(mat' * mat)

end

function spd(rows, cols, shape::Shape.UpperTriangular, properties, positive::Bool)
  throw(ErrorException("Triangular matrix cannot be symmetric positive definite!"))
end

function spd(rows, cols, shape::Shape.LowerTriangular, properties, positive::Bool)
  throw(ErrorException("Triangular matrix cannot be symmetric positive definite!"))
end

"""
  A diagonal matrix is SPD iff all entries are positive.
"""
function spd(rows, cols, shape::Shape.Diagonal, properties, positive::Bool)
  if rows != cols
    throw(ErrorException("A non-square diagonal matrix cannot be symmetric positive definite!"))
  end
  return Diagonal( vec(rand(rows, 1)) )
end
