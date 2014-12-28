local utils = require "utils"
local collision = require "src/hawk/collision"

local map = {
  width = 10,
  height = 10,
  tilewidth = 24,
  tileheight = 24,
  tilelayers = {
    {name = 'collision', tiles = {}},
  }
}

local smallmap = {
  width = 3,
  height = 3,
  tilewidth = 10,
  tileheight = 10,
  tilelayers = {
    {name = 'collision', tiles = {}},
  }
}

local rectmap = {
  width = 4,
  height = 3,
  tilewidth = 10,
  tileheight = 10,
  tilelayers = {
    {name = 'collision', tiles = {}},
  }
}



--Given a map and a bounding box, Return the rows of collision
function test_find_layer() 
  assert_table(collision.find_collision_layer(map))
end


--Given a map and a bounding box, Return the rows of collision
function test_find_rows() 
  local x, y = collision.move(map, {character={direction="right"}}, 0, 0, 24, 24, 0, 0)
  assert_equal(0, x)
  assert_equal(0, y)
end

function test_interpolate() 
  assert_equal(12, collision.interpolate(0, 12, 0, 24, 24))
end

function test_interpolate_bounds() 
  assert_equal(24, collision.interpolate(0, 25, 0, 24, 24))
  assert_equal(0, collision.interpolate(0, -2, 0, 24, 24))
end


function test_scan_rows_invalid_direction()
  assert_error(function()
    collision.scan_rows(map, 28, 28, 12, 12, 'foo')
  end)
end

function test_scan_rows_right()
  local rows = collision.scan_rows(map, 28, 4, 12, 12, 'right')
  assert_values({2,3,4,5,6,7,8,9,10}, rows)
end


function test_scan_rows_left()
  local rows = collision.scan_rows(map, 28, 4, 12, 12, 'left')
  assert_values({2,1}, rows)
end

function test_scan_rows_left_second_rows()
  local rows = collision.scan_rows(map, 28, 28, 12, 12, 'left')
  assert_values({12,11}, rows)
end

function test_scan_rows_left_span_two_rows()
  local rows = collision.scan_rows(map, 28, 4, 12, 30, 'left')
  assert_values({2,12,1,11}, rows)
end

function test_scan_rows_right_span_two_rows()
  local rows = collision.scan_rows(map, 28, 4, 12, 30, 'right')
  assert_values({2,12,3,13,4,14,5,15,6,16,7,17,8,18,9,19,10,20}, rows)
end

function test_scan_cols_up()
  local cols = collision.scan_cols(map, 4, 28, 12, 12, 'up')
  assert_values({11,1}, cols)
end

function test_scan_cols_down()
  local cols = collision.scan_cols(map, 4, 28, 12, 12, 'down')
  assert_values({11,21,31,41,51,61,71,81,91}, cols)
end

function test_scan_cols_up_span_two()
  local cols = collision.scan_cols(map, 4, 28, 24, 12, 'up')
  assert_values({11,12,1,2}, cols)
end


function test_scan_cols_down_span_two()
  local cols = collision.scan_cols(map, 4, 28, 24, 12, 'down')
  assert_values({11,12,21,22,31,32,41,42,51,52,61,62,71,72,81,82,91,92}, cols)
end

-- 1 2 3
-- 4 5 6
-- 7 8 9
function test_small_position_five()
  assert_values({5,2}, collision.scan_cols(smallmap, 10, 10, 10, 10, 'up'))
  assert_values({5,8}, collision.scan_cols(smallmap, 10, 10, 10, 10, 'down'))
  assert_values({5,4}, collision.scan_rows(smallmap, 10, 10, 10, 10, 'left'))
  assert_values({5,6}, collision.scan_rows(smallmap, 10, 10, 10, 10, 'right'))
end

function test_current_tile()
  assert_equal(1, collision.current_tile(rectmap, 0, 0, 9, 9))
  assert_equal(2, collision.current_tile(rectmap, 10, 0, 9, 9))
  assert_equal(3, collision.current_tile(rectmap, 20, 0, 9, 9))
  assert_equal(4, collision.current_tile(rectmap, 30, 0, 9, 9))
  assert_equal(5, collision.current_tile(rectmap, 0, 10, 9, 9))
  assert_equal(6, collision.current_tile(rectmap, 10, 10, 9, 9))
  assert_equal(7, collision.current_tile(rectmap, 20, 10, 9, 9))
  assert_equal(8, collision.current_tile(rectmap, 30, 10, 9, 9))
  assert_equal(9, collision.current_tile(rectmap, 0, 20, 9, 9))
end


function test_small_position_oversize()
  assert_values({5,6,2,3}, collision.scan_cols(smallmap, 10, 10, 11, 11, 'up'))
  assert_values({5,6,8,9}, collision.scan_cols(smallmap, 10, 10, 11, 11, 'down'))
  assert_values({5,8,4,7}, collision.scan_rows(smallmap, 10, 10, 11, 11, 'left'))
  assert_values({5,8,6,9}, collision.scan_rows(smallmap, 10, 10, 11, 11, 'right'))
end

function test_slope_edges()
  local front, back = collision.slope_edges(3)
  assert_equal(front, 23)
  assert_equal(back, 12)
  local front, back = collision.slope_edges(29)
  assert_equal(front, 23)
  assert_equal(back, 12)

end
