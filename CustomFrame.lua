require("Utils")

local custom_frame
local module_slots_panel
Module_slots = { }

selection = {
    building = nil,
    recipe = nil,
    available_modules = Modules_Profiles.Speeds,
    selected_modules = { }
}

local dynamic_fields = { 
    mono = {
        yield_per_second = nil,
        effective_craft_time = nil
    },

    machine_to_yield = {
        input_field = nil,
        result = nil
    },

    yield_to_machine = {
        input_field = nil,
        result = nil
    }
}

local recipe_selector

local function create_title_bar(target_frame)
    local titlebar = target_frame.add { type = "flow" }

    titlebar.drag_target = target_frame
    titlebar.add {
        type = "label",
        style = "frame_title",
        caption = "Performance calculator",
        ignored_by_interaction = true
    }

    local filler = titlebar.add {
        type = "empty-widget",
        style = "draggable_space",
        ignored_by_interaction = true
    }

    filler.style.height = 24
    filler.style.horizontally_stretchable = true

    titlebar.add {
        type = "sprite-button",
        name = Frame_Panels_Names.title_bar.close_button_name,
        style = "frame_action_button",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        tooltip = { "gui.close-instruction" }
    }
end

local function create_building_configuration(target_frame)
    local craft_settings = Add_flow_panel(target_frame, "horizontal")
    local data_config = Add_inner_panel(craft_settings)

    data_config.add { type = "label", caption = "Crafting Machine Settings", style = "heading_1_label" }
    data_config.add { type = "line" }


    local config_hor_flow = Add_flow_panel(data_config, "horizontal")
    config_hor_flow.style.top_margin = 20
    
    Add_space_in(config_hor_flow, true, false)
    
    -- --BUILDING SELECTOR
    local machine_vert_flow = Add_flow_panel(config_hor_flow)
    local title  = Center_element_horizontally_in_parent(machine_vert_flow,  {  type = "label", caption = "Target Crafting Machine" })
    local building_selector = Center_element_horizontally_in_parent(machine_vert_flow, GUI_Element_Definition.Building_Selector_GUI_Element)
    building_selector.style.size = 100
    -- --------------------------------------
    
    Add_space_in(config_hor_flow, true, false)
    
    --Subtitle
    local subtitle_flow = Add_flow_panel(machine_vert_flow, "horizontal")
    subtitle_flow.style.top_margin = 20
    Add_space_in(subtitle_flow, true, false)
    local subtitle = subtitle_flow.add { type = "label", caption ="Module Settings"}
    Add_space_in(subtitle_flow, true, false)
    -- Add_space_in(subtitle_flow)
    
    local module_container_panel = Add_flow_panel(machine_vert_flow)
    local vert = Test_Panel(module_container_panel)
    -- Add_space_in(vert, false, true)
    -- module_container_panel.style.vertically_stretchable = true
    
    module_slots_panel = Add_flow_panel(vert, "horizontal")
    module_slots_panel.style.height = Frame_Settings.module_slot_size + 20
    module_slots_panel.style.horizontally_stretchable = true
    -- Add_space_in(vert, false, true)
    
    -- --RECIPE SELECTOR 
    local recipe_vert_flow = Add_flow_panel(config_hor_flow)
    title  = Center_element_horizontally_in_parent(recipe_vert_flow,  {  type = "label", caption = "Target Recipe" })
    recipe_selector = Center_element_horizontally_in_parent(recipe_vert_flow, GUI_Element_Definition.Recipe_Selector_GUI_Element)
    recipe_selector.style.size = 100
    -- --------------------------------------
    
    Add_space_in(config_hor_flow, true, false)
    -- filler = Add_filler(config_hor_flow)
    -- filler.style.horizontally_stretchable = true    
end
   

local function update_module_slots()
    local current_slot
    for i=1, #Module_slots do
        current_slot = Module_slots[i]
        current_slot.elem_filters = { {filter = "name", name = selection.available_modules } }

        local keep = false
        for j=1, #selection.available_modules do
            if current_slot.elem_value ~= nil and current_slot.elem_value == selection.available_modules[j] then
                keep = true
            end
        end

        if not keep then
            current_slot.elem_value = nil
        end
    end
end


local function create_machine_performance(frame)

    local main_container = Add_flow_panel(frame)
    local fillers = { }
    
    -- a
    main_container.add { type = "label", caption = "Computed Performances", style = "heading_1_label" }
    main_container.add { type = "line" }

    -- b
    local mono_yield_container = Add_flow_panel(main_container, "horizontal")
    mono_yield_container.style.horizontally_stretchable = true
    fillers[#fillers+1] = Add_filler(mono_yield_container)
    
    local yield_per_sec = Add_flow_panel(mono_yield_container)
    yield_per_sec.style.vertically_stretchable = true
    
    Center_element_horizontally_in_parent(yield_per_sec, { type = "label", caption = "Yield Per Second", style = "heading_1_label" } )
    local mono_yield_panel = Center_element_horizontally_in_parent(yield_per_sec, { type = "label", name = Frame_Panels_Names.machine_performance.mono_perf.yield_per_sec, caption = "settings incorrect for computation" } )
    dynamic_fields.mono.yield_per_second = mono_yield_panel

    fillers[#fillers+1] = Add_filler(mono_yield_container)
    
    local actual_craft_time = Add_flow_panel(mono_yield_container)
    actual_craft_time.style.vertically_stretchable = true
    
    Center_element_horizontally_in_parent(actual_craft_time, { type = "label", caption = "Effective Craft Time", style = "heading_1_label" } )
    local effective_craft_time_panel = Center_element_horizontally_in_parent(actual_craft_time, { type = "label", name = Frame_Panels_Names.machine_performance.mono_perf.actual_craft_time, caption = "settings incorrect for computation" })
    dynamic_fields.mono.effective_craft_time = effective_craft_time_panel

    fillers[#fillers+1] = Add_filler(mono_yield_container)
    
    for i=1, #fillers, 1 do
        fillers[i].style.horizontally_stretchable = true
    end

    fillers = { }
    
    -- c
    local machine_to_yield_container = Add_flow_panel( main_container )
    Center_element_horizontally_in_parent(machine_to_yield_container,  { type = "label", caption = "product/sec with X machines", style = "heading_1_label" })

    local field_container = Add_flow_panel( machine_to_yield_container, "horizontal" )
    local left = Add_flow_panel( field_container )
    local title = Center_element_horizontally_in_parent(left, { type = "label", caption = "Machine Count", style ="heading_2_label" })
    dynamic_fields.machine_to_yield.input_field = Center_element_horizontally_in_parent(left, { 
        type = "textfield",
        name = Frame_Panels_Names.machine_performance.machine_to_yield.input_field,
        clear_and_focus_on_right_click = true,
        numeric = true
    })
    
    Add_space_in(field_container, true, false)
    
    local produce = Add_flow_panel(field_container)
    Add_space_in(produce, true, true)
    produce.add { type = "label", caption = "------------------>", style = "heading_2_label" }
    Add_space_in(produce, true, true)

    Add_space_in(field_container, true, false)

    local right = Add_flow_panel( field_container )
    Center_element_horizontally_in_parent(right, { type = "label", caption = "Yield", style ="heading_2_label" })
    local machine_to_yield_res_panel = Center_element_horizontally_in_parent(right, { type = "label", name = Frame_Panels_Names.machine_performance.machine_to_yield.yield_result, caption = "settings incorrect for computation"})
    dynamic_fields.machine_to_yield.result = machine_to_yield_res_panel

    Add_space_in(main_container, false, true)

    -- d
    local machine_to_yield_container = Add_flow_panel( main_container )
    Center_element_horizontally_in_parent( machine_to_yield_container,  {type = "label", caption = "product/sec with X machines", style = "heading_1_label" })
    local field_container = Add_flow_panel( machine_to_yield_container, "horizontal" )

    local left = Add_flow_panel( field_container )
    local title = Center_element_horizontally_in_parent(left, { type = "label", caption = "Target Yield", style ="heading_2_label" })
    dynamic_fields.yield_to_machine.input_field = Center_element_horizontally_in_parent(left, { 
        type = "textfield",
        name = Frame_Panels_Names.machine_performance.yield_to_machine.input_field,
        clear_and_focus_on_right_click = true,
        numeric = true
    })    
    Add_space_in(field_container, true, false)
    
    local produce = Add_flow_panel(field_container)
    Add_space_in(produce, true, true)
    produce.add { type = "label", caption = "------------------>", style = "heading_2_label" }
    Add_space_in(produce, true, true)
    
    Add_space_in(field_container, true, false)
    local right = Add_flow_panel( field_container )
    Center_element_horizontally_in_parent(right, { type = "label", caption = "Necessary machines", style ="heading_2_label" })
    local yield_to_machine_res_panel = Center_element_horizontally_in_parent(right, { type = "label", name = Frame_Panels_Names.machine_performance.yield_to_machine.yield_result, caption = "settings incorrect for computation"})
    dynamic_fields.yield_to_machine.result = yield_to_machine_res_panel

end


function Update_Performances()
    global.selection = selection
    if selection.building == nil or selection.recipe == nil then return end

    local recipe_prototype = game.recipe_prototypes[selection.recipe.name]
    local machine_prototype = game.entity_prototypes[selection.building.name]

    local init_machine_speed = machine_prototype.crafting_speed
    local effective_machine_speed = init_machine_speed

    for i=1, #Module_slots, 1 do
        local elem_value = Module_slots[i].elem_value
        if elem_value ~= nil then 
            local bonus_ratio = game.item_prototypes[elem_value].module_effects.speed.bonus
            effective_machine_speed = effective_machine_speed + ( init_machine_speed * bonus_ratio)
        end
    end

    
    local crafting_time = recipe_prototype.energy / effective_machine_speed
    local yield_per_second = (1/crafting_time)/recipe_prototype.products[1].amount
    crafting_time = Truncate_float_to_decimal_count(crafting_time, 2)
    dynamic_fields.mono.effective_craft_time.caption = tostring(crafting_time)
    dynamic_fields.mono.yield_per_second.caption = Truncate_float_to_decimal_count(yield_per_second, 2)

    Update_yield_to_machine( dynamic_fields.yield_to_machine.input_field.text )
    Update_machine_to_yield( dynamic_fields.machine_to_yield.input_field.text )
end

function Update_yield_to_machine( target_yield )
    if selection.building == nil or selection.recipe == nil or target_yield == "" then
        dynamic_fields.yield_to_machine.result.caption = "settings incorrect for computation"
        return
    end
    local mono_yield = tonumber(dynamic_fields.mono.yield_per_second.caption)
    dynamic_fields.yield_to_machine.result.caption = math.ceil(tonumber(target_yield) / mono_yield)
end

function Update_machine_to_yield( machine_count )
    if selection.building == nil or selection.recipe == nil or machine_count == "" then
        dynamic_fields.machine_to_yield.result.caption = "Settings incorrect for computation"
        return
    end
    local mono_yield = tonumber(dynamic_fields.mono.yield_per_second.caption)
    dynamic_fields.machine_to_yield.result.caption = tonumber(machine_count) * mono_yield

end

function Update_Recipe_Selection(selected_recipe)

    if selected_recipe == nil then
        selection.recipe = nil
        return
    end


    --[[  SELECTIVE MODULES ACCORDING TO RECIPE 
    Currently unsupported as effectivity modules irrelevant for yield calculation purposes
    and producitivity modules would require a whole sub section for related effects.

    selection.available_modules = Modules_Profiles.Basics
    if selected_recipe.subgroup.name == "intermediate-product" then
        selection.available_modules = Modules_Profiles.intermediate_products
    end
    
    if selection.building ~= nil then
        if selection.building.subgroup.name == "smelting-machine" then
            selection.available_modules = Modules_Profiles.intermediate_products
        end
    end
    ]]--

    selection.available_modules = Modules_Profiles.Speeds

    selection.recipe = selected_recipe

    update_module_slots()
    Update_Performances()
end

function Update_Building_Selection(selected_building)

    if selected_building == nil then
        selection.building = nil
        module_slots_panel.clear()
        Module_slots = { }
        Update_Performances()
        return
    end

    local categories = selected_building.crafting_categories
    selection.building = selected_building

    local filter = {}
    local current_recipe_compat = false
    local current_recipe_category = nil

    if recipe_selector.elem_value ~= nil then
        current_recipe_category = game.recipe_prototypes[recipe_selector.elem_value].category
    end


    for current_category, v in pairs(categories) do
        table.insert(filter, { filter = "category", category = current_category })

        if current_recipe_category ~= nil and current_category == current_recipe_category then
            current_recipe_compat = true
        end
    end

    recipe_selector.elem_filters = filter

    if not current_recipe_compat then
        recipe_selector.elem_value = nil
    end

    
    module_slots_panel.clear()
    Module_slots = { }
    local module_hor_flow = Add_flow_panel(module_slots_panel, "horizontal")

    
    local new_slot
    module_hor_flow.style.top_margin = 10
    module_hor_flow.style.bottom_margin = 10
    local filler = Add_filler(module_hor_flow)
    filler.style.horizontally_stretchable = true

    for i=1, selected_building.module_inventory_size, 1 do
        new_slot = module_hor_flow.add(GUI_Element_Definition.Module_Element_Chooser)
        new_slot.style.size = Frame_Settings.module_slot_size
        new_slot.name = "module-slot-" .. i
        table.insert(Module_slots, new_slot)
        local filler = Add_filler(module_hor_flow)
        filler.style.horizontally_stretchable = true
    end

    update_module_slots()
    Update_Performances()
end

function Build_interface(player)
    local screen = player.gui.screen
    custom_frame = screen.add { type = "frame", name = frame_name, direction = "vertical" }
    custom_frame.style.size = Frame_Settings.size
    custom_frame.auto_center = true
    create_title_bar(custom_frame)
    create_building_configuration(custom_frame)
    create_machine_performance(custom_frame)
    player.opened = custom_frame
end