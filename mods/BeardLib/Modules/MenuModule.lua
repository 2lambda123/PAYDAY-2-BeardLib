MenuModule = MenuModule or class(ModuleBase)
MenuModule.type_name = "Menu"

function MenuModule:init(core_mod, config)
    self.required_params = table.add(clone(self.required_params), {"menu"})
    if not self.super.init(self, core_mod, config) then
        return false
    end

    self:create_hooks()

    return true
end

function MenuModule:create_hooks()
    Hooks:Add("MenuManagerSetupCustomMenus", self._mod.Name .. "Build" .. self._name .. "Menu", function(self_menu, nodes)
        self:build_node(self._config.menu, nodes[LuaModManager.Constants._lua_mod_options_menu_id])
    end)
end

function MenuModule:build_node_items(node, data)
    for i, sub_item in ipairs(data) do
        if sub_item._meta == "sub_menu" or sub_item._meta == "menu" then
            if sub_item.key then
                if self._mod[sub_item.key] then
                    self._mod[sub_item.key]:BuildMenu(node)
                else
                    self:log("[ERROR] Cannot find module of id '%s' in mod", sub_item.key)
                end
            else
                self:build_node(sub_item, node)
            end
        elseif sub_item._meta == "item_group" then
            if sub_item.key then
                if self._mod[sub_item.key] then
                    self._mod[sub_item.key]:InitializeNode(node)
                else
                    self:log("[ERROR] Cannot find module of id '%s' in mod", sub_item.key)
                end
            else
                self:log("[ERROR] item_group must contain a definition for the parameter 'key'")
            end
        elseif sub_item._meta == "divider" then
            self:CreateDivider(node, sub_item)
        end
    end
end

function MenuModule:CreateDivider(parent_node, tbl)
    local merge_data = tbl.merge_data or {}
    merge_data = BeardLib.Utils:RemoveAllNumberIndexes(merge_data)
    MenuHelperPlus:AddDivider(table.merge({
        id = tbl.name,
        node = parent_node,
        size = tbl.size
    }, merge_data))
end

function MenuModule:build_node(node_data, parent_node)
    parent_node = node_data.parent_node and MenuHelperPlus:GetNode(node_data.parent_node) or parent_node
    local base_name = node_data.name or self._mod.Name .. self._name
    local menu_name = node_data.node_name or base_name .. "Node"

    local merge_data = node_data.merge_data or {}
    merge_data = BeardLib.Utils:RemoveAllNumberIndexes(merge_data)
    local main_node = MenuHelperPlus:NewNode(nil, table.merge({
        name = menu_name
    }, merge_data))

    self:build_node_items(main_node, node_data)

    MenuHelperPlus:AddButton({
        id = base_name .. "Button",
        title = node_data.title_id or base_name .. "ButtonTitleID",
        desc = node_data.desc_id or base_name .. "ButtonDescID",
        node = parent_node,
        next_node = menu_name
    })

    managers.menu:add_back_button(main_node)
end

BeardLib:RegisterModule(MenuModule.type_name, MenuModule)