anus.MenuCategories = {}

function anus.AddCategory( tbl )
	anus.MenuCategories[ tbl.CategoryName ] =
	{
	pluginid = tbl.pluginid,
	CategoryName = tbl.CategoryName,
	Initialize = tbl.Initialize, 
	}
end