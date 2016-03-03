physics = {}

function physics:update(dt)
	for objName, v in pairs(objects) do
		for _, objData in pairs(v) do

			for obj2Name, t in pairs(objects) do

				if v ~= t then
					for _, obj2Data in pairs(t) do
						if self:aabb(objData.x, objData.y, objData.width, objData.height, obj2Data.x, obj2Data.y, obj2Data.width, obj2Data.height) then
							if objData.onCollide then
								objData:onCollide(obj2Name, obj2Data)
							end
						end	
					end
				end
			end
		end
	end
end

function physics:aabb(x, y, w, h, x2, y2, w2, h2)
	return (x + w > x2) and (x < x2 + w2) and (y + h > y2) and (y < y2 + h2)
end