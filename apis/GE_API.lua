GE = {
    initialized = false,
    items = {},
    item_keys = {},
    injections = {},
}

function GE:init()
    if GE.initialized == false then
        GE.initialized = true
        injectTail("card.lua", "Card:set_sprites", [[
            if _center then
                if _center.set then
                    if (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and _center.atlas 
                        and (_center.unlocked or _center.unlocked == nil or self.params.bypass_discovery_center) then
                        self.children.center.atlas = G.ASSET_ATLAS
                        [(_center.atlas or (_center.set == 'Joker' or _center.consumeable or _center.set == 'Voucher') and _center.set) or 'centers']
                        self.children.center:set_sprite_pos(_center.pos)
                    end
                end
            end]]);

        inject("card.lua", "Card:generate_UIBox_ability_table", "local badges", [[
        if self.config and self.config.center and self.config.center.loc_var_func then
            loc_vars = self.config.center.loc_var_func(self);
        end
        local badges]]);
        inject("functions/common_events.lua", "generate_card_ui", ", vars = loc_vars%}", ", vars = (specific_vars and #specific_vars and specific_vars) or loc_vars}");

        injectTail("game.lua", "Game:init_item_prototypes", [[
            GE:refresh_items();
]]);
    end
end

function GE:refresh_sprites()
end

function GE:inject(mod_id, path, function_name, to_replace, replacement)
    if GE.injections[mod_id] == nil then
        GE.injections[mod_id] = {}
    end
    table.insert(GE.injections[mod_id], {path = path, function_name = function_name, to_replace = to_replace, replacement = replacement})
    inject(path, function_name, to_replace:gsub("([^%w])", "%%%1"), replacement:gsub("([^%w])", "%%%1"));
end

-- Note: px and py are optional
function GE:add_item(mod_id, pool, id, data, desc, px, py)
    if data.unlocked == nil then
        data.unlocked = true;
    end
    if data.discovered == nil then
        data.discovered = true;
    end

    -- Add Sprite
    if data.pos == nil then
        data.pos = {x=0,y=0};
    end
    if px == nil then
        px = 71
    end
    if py == nil then
        py = 95
    end
    data.key = id;
    data.atlas = mod_id .. id;
    GE:add_sprite(mod_id, id, px, py)

    if GE.items[mod_id] == nil then
        GE.items[mod_id] = {}
    end

    GE.items[mod_id][id] = {
        id = id,
        pool = pool,
        data = data,
        desc = desc,
        px = px,
        py = py
    }
    table.insert(GE.item_keys, {mod_id = mod_id, id = id});
end

function GE:refresh_items()
    for _, v in pairs(GE.item_keys) do
        local item = GE.items[v.mod_id][v.id]
        if G.P_CENTERS[item.id] == nil then
            item.data.order = #G.P_CENTER_POOLS[item.pool] + 1
            G.P_CENTERS[item.id] = item.data
            table.insert(G.P_CENTER_POOLS[item.pool], item.data)
            
            if item.pool == "Joker" then
                table.insert(G.P_JOKER_RARITY_POOLS[item.data.rarity], item.data)
            end
        
            G.localization.descriptions[item.pool][item.id] = item.desc;
        end
    end

    for k, v in pairs(G.P_CENTER_POOLS) do
        table.sort(v, function(a, b) return a.order < b.order end)
    end

    -- Update localization
    for g_k, group in pairs(G.localization) do
        if g_k == 'descriptions' then
            for _, set in pairs(group) do
                for _, center in pairs(set) do
                    center.text_parsed = {}
                    for _, line in ipairs(center.text) do
                        center.text_parsed[#center.text_parsed + 1] = loc_parse_string(line)
                    end
                    center.name_parsed = {}
                    for _, line in ipairs(type(center.name) == 'table' and center.name or { center.name }) do
                        center.name_parsed[#center.name_parsed + 1] = loc_parse_string(line)
                    end
                    if center.unlock then
                        center.unlock_parsed = {}
                        for _, line in ipairs(center.unlock) do
                            center.unlock_parsed[#center.unlock_parsed + 1] = loc_parse_string(line)
                        end
                    end
                end
            end
        end
    end

    for k, v in pairs(G.P_JOKER_RARITY_POOLS) do 
        table.sort(G.P_JOKER_RARITY_POOLS[k], function (a, b) return a.order < b.order end)
    end
end

function GE:add_sprite(mod_id, id, px, py)
    table.insert(G.asset_atli, {name = mod_id .. id, path = "assets/" .. mod_id .. "/" .. id .. ".png", px = px, py = py})
    local imagedata = love.graphics.newImage("assets/" .. mod_id .. "/" .. id .. ".png")
    imagedata:setFilter("nearest")
    canvas = love.graphics.newCanvas(px * G.SETTINGS.GRAPHICS.texture_scaling, py * G.SETTINGS.GRAPHICS.texture_scaling)

    love.graphics.setCanvas(canvas)
        love.graphics.draw(imagedata, 0, 0, 0, G.SETTINGS.GRAPHICS.texture_scaling)
    love.graphics.setCanvas()

    imagedata = canvas:newImageData()

    G.ASSET_ATLAS[mod_id .. id] = {
        name = mod_id .. id,
        image = love.graphics.newImage(imagedata, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling}),
        type = "asset_atli",
        px = px,
        py = py,
        custom = true;
    }
end

function GE:disable(mod_id)
    for k, v in pairs(GE.items[mod_id]) do
        G.P_JOKER_RARITY_POOLS[G.P_CENTER_POOLS[v.pool][v.id].rarity] = nil;
        G.P_CENTER_POOLS[v.pool][v.id] = nil;
        G.localization.descriptions[v.pool][v.id] = nil;
        G.P_CENTERS[v.id] = nil
    end
    for k, v in pairs(GE.injections[mod_id]) do
        inject(v.path, v.function_name, v.replacement:gsub("([^%w])", "%%%1"), v.to_replace:gsub("([^%w])", "%%%1"));
    end
    GE.items[mod_id] = nil
    GE.item_keys = {}
    GE.injections[mod_id] = {}
    GE:refresh_items();
end