-- PLY Export Script made by Yoshiboy/OrangeDuck
--
-- 		http://theorangeduck.com/page/3ds-max-ply-expoter
--
-- Supports vertex colours and uvs, which if selected, must be defined on all verticies.
-- To use simply select the mesh you want to export and run the script.
--
-- This tool is designed to be used with OpenBRF, a modding tool for Mount & Blade
-- http://forums.taleworlds.com/index.php/board,215.0.html
--
-- Due to this, and the nature of ply files, it is no intended for general use and probably will not work in other contexts.
-- Still, the technique I use is simple, and to fit this to your application may just require some name changes in strings.
--
-- Licensed under The Do What The Fuck You Want To Public License (WTFPL)
-- 		http://sam.zoy.org/wtfpl/
--

global g_flip_normals
global g_vcol_check
global g_vuvs_check
global g_y_z_swap

struct vertex (position, normal, uvs, colours)

-- Used to test struct equality. Returns vertex position if in list otherwise 0
fn vert_list_find list v = (
	
	for i = 1 to list.count do (
		lv = list[i]
		if ( lv.position == v.position and lv.normal == v.normal and lv.uvs == v.uvs and lv.colours == v.colours ) then ( return i )
	)
	
	return 0
)

fn write_file = (
	
	-- Create Save File
	out_name = getSaveFileName types: "Polygon File(*.ply) |*.ply|"
	out_file = createfile out_name	
	
	-- Use Selected Mesh
	tmesh = snapshotAsMesh selection[1]	
	
	vertex_string = ""
	faces_string = ""

	num_verts = 0
	num_faces = tmesh.numfaces
	
	vert_list = #()
	
	-- Loop over all faces in the mesh.
	for f = 1 to num_faces do
	(
		face = getFace tmesh f
		
		p1 = getVert tmesh face[1]
		p2 = getVert tmesh face[2]
		p3 = getVert tmesh face[3]
		
		n1 = getNormal tmesh face[1]
		n2 = getNormal tmesh face[2]
		n3 = getNormal tmesh face[3]
		
		if (not g_flip_normals) then (
			n1 = -n1
			n2 = -n2
			n3 = -n3
		)
		
		if (g_y_z_swap) then (
			swap p1.y p1.z
			swap p2.y p2.z
			swap p3.y p3.z
			
			swap n1.y n1.z
			swap n2.y n2.z
			swap n3.y n3.z
		)
		
		if (g_vuvs_check) then (
			tvface = getTVface tmesh f
			tv1 = getTVert tmesh tvface[1]
			tv2 = getTVert tmesh tvface[2]
			tv3 = getTVert tmesh tvface[3]
		) else (
			tv1 = 0
			tv2 = 0
			tv3 = 0
		)
		
		if (g_vcol_check) then (
			cpface = getVCFace tmesh f
			c1 = getVertColor tmesh cpface[1]
			c2 = getVertColor tmesh cpface[2]
			c3 = getVertColor tmesh cpface[3]
		) else (
			c1 = 0
			c2 = 1
			c3 = 2
		)
		
		v1 = vertex p1 n1 tv1 c1
		v2 = vertex p2 n2 tv2 c2
		v3 = vertex p3 n3 tv3 c3
		
		v1i = vert_list_find vert_list v1
		v2i = vert_list_find vert_list v2
		v3i = vert_list_find vert_list v3
		
		i1 = 0
		i2 = 0
		i3 = 0
		
		if (v1i == 0) then ( -- New Vertex
			append vert_list v1
			vertex_string += (p1.x as string) + " " + (p1.y as string) + " " + (p1.z as string) + " "
			vertex_string += (n1.x as string) + " " + (n1.y as string) + " " + (n1.z as string) + " "
			if (g_vuvs_check) then ( vertex_string += (tv1.x as string) + " " + (tv1.y as string) + " " )
			if (g_vcol_check) then ( vertex_string += (int(c1.r) as string) + " " + (int(c1.g) as string) + " " + (int(c1.b) as string) + " " + (int(c1.a) as string) )
			vertex_string += "\n"
			i1 = num_verts
			num_verts += 1
		) else ( -- Existing Vertex
			i1 = v1i-1
		)
		
		if (v2i == 0) then ( -- New Vertex
			append vert_list v2
			vertex_string += (p2.x as string) + " " + (p2.y as string) + " " + (p2.z as string)+ " "
			vertex_string += (n2.x as string) + " " + (n2.y as string) + " " + (n2.z as string)+ " "
			if (g_vuvs_check) then ( vertex_string += (tv2.x as string) + " " + (tv2.y as string) + " " )
			if (g_vcol_check) then ( vertex_string += (int(c2.r) as string) + " " + (int(c2.g) as string) + " " + (int(c2.b) as string) + " " + (int(c2.a) as string) )
			vertex_string += "\n"
			i2 = num_verts
			num_verts += 1
		) else ( -- Existing Vertex
			i2 = v2i-1
		)
		
		if (v3i == 0) then ( -- New Vertex
			append vert_list v3
			vertex_string += (p3.x as string) + " " + (p3.y as string) + " " + (p3.z as string)+ " "
			vertex_string += (n3.x as string) + " " + (n3.y as string) + " " + (n3.z as string)+ " "
			if (g_vuvs_check) then ( vertex_string += (tv3.x as string) + " " + (tv3.y as string) + " " )
			if (g_vcol_check) then ( vertex_string += (int(c3.r) as string) + " " + (int(c3.g) as string) + " " + (int(c3.b) as string) + " " + (int(c3.a) as string) )
			vertex_string += "\n"
			i3 = num_verts
			num_verts += 1
		) else ( -- Existing Vertex
			i3 = v3i-1
		)
		
		-- If flipping normals then also swap winding order of faces
		if (g_flip_normals) then (
			faces_string += "3 " + (i3 as string) + " " + (i2 as string) + " " + (i1 as string) + "\n"
		) else (
			faces_string += "3 " + (i1 as string) + " " + (i2 as string) + " " + (i3 as string) + "\n"
		)
	)
	
	-- Write Header
	format "ply\n" to:out_file
	format "format ascii 1.0\n" to:out_file

	format "element vertex %\n" num_verts to:out_file
	format "property float x\n" to:out_file
	format "property float y\n" to:out_file
	format "property float z\n" to:out_file
	format "property float nx\n" to:out_file
	format "property float ny\n" to:out_file
	format "property float nz\n" to:out_file
	
	if (g_vuvs_check) then (
		format "property float texture_u\n" to:out_file
		format "property float texture_v\n" to:out_file	
	)
	
	if (g_vcol_check) then ( 
		format "property uchar red\n" to:out_file
		format "property uchar green\n" to:out_file
		format "property uchar blue\n" to:out_file
		format "property uchar alpha\n" to:out_file
	)
	
	format "element face %\n" num_faces to:out_file
	format "property list uchar int vertex_index\n" to:out_file

	format "end_header\n" to:out_file
	
	-- Write data
	format "%" vertex_string to:out_file
	format "%" faces_string to:out_file
	
	close out_file
)

rollout ExportPLYfloater "Export" 
(
	group "Options:"
	(
		checkbox vcol_check "Vertex Colors" checked:true across:2
		checkbox vuvs_check "Vertex UVs" checked:true across:2
		checkbox y_z_swap "Swap Y and Z" checked:true across:2
		checkbox flip_normals "Flip Normals" checked:false across:2
	)
	
	button do_export "Export Object"

	on do_export pressed do (
		g_flip_normals = flip_normals.checked
		g_vuvs_check = vuvs_check.checked
		g_vcol_check = vcol_check.checked
		g_y_z_swap = y_z_swap.checked
		write_file()
	)
)

if myPLYFloater != undefined then (
	closeRolloutFloater myPLYFloater
)

myPLYFloater = newRolloutFloater "PLY Export" 256 128
addRollout ExportPLYfloater myPLYFloater