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

--Given a map and a bounding box, Return the rows of collision
function test_find_layer() 
  assert_table(collision.find_collision_layer(map))
end


--Given a map and a bounding box, Return the rows of collision
function test_find_rows() 
  local x, y = collision.move(map, 0, 0, 24, 24, 0, 0)
  assert_equal(0, x)
  assert_equal(0, y)
end

function test_scan_rows_right()
  local rows = collision.scan_rows(map, 28, 4, 12, 12, 'right')
  assert_values({2,3,4,5,6,7,8,9,10}, rows)
end

function test_scan_rows_invalid_direction()
  assert_error(function()
    collision.scan_rows(map, 28, 28, 12, 12, 'foo')
  end)
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

--
--function test_bounding_box_just_bigger() 
--  local rows, cols = collision.touching(map, 0, 0, 25, 25)
--  assert_values({1, 2}, rows)
--  assert_values({1, 2}, cols)
--end
--
--function test_bounding_box_just_wider() 
--  local rows, cols = collision.touching(map, 0, 0, 25, 24)
--  assert_values({1, 2}, rows)
--  assert_values({1}, cols)
--end
--
--function test_bounding_box_just_taller()
--  local rows, cols = collision.touching(map, 0, 0, 24, 25)
--  assert_values({1}, rows)
--  assert_values({1, 2}, cols)
--end



--Given a map and a bounding box, Return the columns of collision

