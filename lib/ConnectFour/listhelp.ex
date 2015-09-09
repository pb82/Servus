defmodule Listhelp do
  defp put_item([], result, _, _, _) do
    result
  end

  defp put_item([h|t], result, index, cindex, item) do
    if index == cindex do
      put_item(t, [item | result], index, cindex + 1, item)
    else
      put_item(t, [h | result], index, cindex + 1, item)
    end
  end
  
  def put_item(list, index, item) do
    Enum.reverse(put_item(list, [], index, 0, item))
  end
end

defmodule Fieldchecker do
  defp count([], last, result) do
    {last, result}
  end

  defp count(_, last, 4) do
    {last, 4}
  end

  defp count([nil|t], last, result) do
    count(t, last, 0)
  end

  defp count([h|t], last, result) do
    if h == last do
      count(t, last, result + 1) 
    else
      count(t, h, 1)
    end
  end

  def count(list) do
    count(list, Enum.at(list, 0), 0)
  end

  def rotate(field) do
    [
      [a0, a1, a2, a3, a4, a5, a6, a7],
      [b0, b1, b2, b3, b4, b5, b6, b7],
      [c0, c1, c2, c3, c4, c5, c6, c7],
      [d0, d1, d2, d3, d4, d5, d6, d7],
      [e0, e1, e2, e3, e4, e5, e6, e7],
      [f0, f1, f2, f3, f4, f5, f6, f7],
      [g0, g1, g2, g3, g4, g5, g6, g7],
      [h0, h1, h2, h3, h4, h5, h6, h7]
    ] = field

    [
      [h0, g0, f0, e0, d0, c0, b0, a0],
      [h1, g1, f1, e1, d1, c1, b1, a1],
      [h2, g2, f2, e2, d2, c2, b2, a2],
      [h3, g3, f3, e3, d3, c3, b3, a3],
      [h4, g4, f4, e4, d4, c4, b4, a4],
      [h5, g5, f5, e5, d5, c5, b5, a5],
      [h6, g6, f6, e6, d6, c6, b6, a6],
      [h7, g7, f7, e7, d7, c7, b7, a7]
    ]
  end
  def arrow_right(field) do
    [
      [a0, a1, a2, a3, a4, a5, a6, a7],
      [b0, b1, b2, b3, b4, b5, b6, b7],
      [c0, c1, c2, c3, c4, c5, c6, c7],
      [d0, d1, d2, d3, d4, d5, d6, d7],
      [e0, e1, e2, e3, e4, e5, e6, e7],
      [f0, f1, f2, f3, f4, f5, f6, f7],
      [g0, g1, g2, g3, g4, g5, g6, g7],
      [h0, h1, h2, h3, h4, h5, h6, h7]
    ] = field

    [
      [d0, c1, b2, a3],
      [e0, d1, c2, b3, a4],
      [f0, e1, d2, c3, b4, a5],
      [g0, f1, e2, d3, c4, b5, a6],
      [h0, g1, f2, e3, d4, c5, b6, a7],
      [h1, g2, f3, e4, d5, c6, b7],
      [h2, g3, f4, e5, d6, c7],
      [h3, g4, f5, e6, d7],
      [h4, g5, f6, e7]
    ]
  end

  def arrow_left(field) do
    [
      [a0, a1, a2, a3, a4, a5, a6, a7],
      [b0, b1, b2, b3, b4, b5, b6, b7],
      [c0, c1, c2, c3, c4, c5, c6, c7],
      [d0, d1, d2, d3, d4, d5, d6, d7],
      [e0, e1, e2, e3, e4, e5, e6, e7],
      [f0, f1, f2, f3, f4, f5, f6, f7],
      [g0, g1, g2, g3, g4, g5, g6, g7],
      [h0, h1, h2, h3, h4, h5, h6, h7]
    ] = field

    [
                      [a4, b5, c6, d7],
                  [a3, b4, c5, d6, e7],
              [a2, b3, c4, d5, e6, f7],
          [a1, b2, c3, d4, e5, f6, g7],
      [a0, b1, c2, d3, e4, f5, g6, h7],
          [b0, c1, d2, e3, f4, g5, h6],
              [c0, d1, e2, f3, g4, h5],
                  [d0, e1, f2, g3, h4],
                      [e0, f1, g2, h3]
    ]
  end
end
