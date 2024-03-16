GE = {
    initialized = false,
    items = {},
    item_keys = {},
    injections = {},
    card_effects = {},
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
        inject("functions/common_events.lua", "generate_card_ui", ", vars = loc_vars%}", ", vars = ((specific_vars and #specific_vars ~= 0) and specific_vars) or loc_vars}");
        
        injectTail("game.lua", "Game:init_item_prototypes", [[
            GE:refresh_items();
]]);
        
    injectTail("card.lua", "Card:set_ability", [[
        GE:card_effect(self, {}, "init");
    ]]);
    injectHead("card.lua", "Card:calculate_joker", [[
        if self.ability.set == "Joker" and not self.debuff then
            if context.open_booster then
                local ret_val = GE:card_effect(self, context, "open_booster")
                if ret_val then return ret_val end
            elseif context.buying_card then
                local ret_val = GE:card_effect(self, context, "buy_card")
                if ret_val then return ret_val end
            elseif context.selling_self then
                local ret_val = GE:card_effect(self, context, "sell_self")
                if ret_val then return ret_val end
            elseif context.selling_card then
                local ret_val = GE:card_effect(self, context, "sell_card")
                if ret_val then return ret_val end
            elseif context.reroll_shop then
                local ret_val = GE:card_effect(self, context, "reroll_shop")
                if ret_val then return ret_val end
            elseif context.ending_shop then
                local ret_val = GE:card_effect(self, context, "end_shop")
                if ret_val then return ret_val end
            elseif context.skip_blind then
                local ret_val = GE:card_effect(self, context, "skip_blind")
                if ret_val then return ret_val end
            elseif context.skipping_booster then
                local ret_val = GE:card_effect(self, context, "skip_booster")
                if ret_val then return ret_val end
            elseif context.playing_card_added and not sopen_boosterelf.getting_sliced then
                local ret_val = GE:card_effect(self, context, "add_card")
                if ret_val then return ret_val end
            elseif context.first_hand_drawn then
                local ret_val = GE:card_effect(self, context, "start_round")
                if ret_val then return ret_val end
            elseif context.setting_blind and not self.getting_sliced then
                local ret_val = GE:card_effect(self, context, "setup_round")
                if ret_val then return ret_val end
            elseif context.destroying_card and not context.blueprint then
                local ret_val = GE:card_effect(self, context, "pre_destroy_card")
                if ret_val then return ret_val end
            elseif context.cards_destroyed then
                local ret_val = GE:card_effect(self, context, "destroy_card")
                if ret_val then return ret_val end
            elseif context.remove_playing_cards then
                local ret_val = GE:card_effect(self, context, "post_destroy_card")
                if ret_val then return ret_val end
            elseif context.using_consumable then
                local ret_val = GE:card_effect(self, context, "use_consumable")
                if ret_val then return ret_val end
            elseif context.debuffed_hand then
                local ret_val = GE:card_effect(self, context, "play_debuffed")
                if ret_val then return ret_val end
            elseif context.pre_discard then
                local ret_val = GE:card_effect(self, context, "pre_discard")
                if ret_val then return ret_val end
            elseif context.discard then
                local ret_val = GE:card_effect(self, context, "discard")
                if ret_val then return ret_val end
            elseif context.end_of_round then
                if context.individual then
                    if context.cardarea == G.play then
                        local ret_val = GE:card_effect(self, context, "play_individual_end_round")
                        if ret_val then return ret_val end
                    end
                    if context.cardarea == G.hand then
                        local ret_val = GE:card_effect(self, context, "hand_individual_end_round")
                        if ret_val then return ret_val end
                    end
                elseif context.repetition then
                    if context.cardarea == G.play then
                        local ret_val = GE:card_effect(self, context, "play_repetition_end_round")
                        if ret_val then return ret_val end
                    end
                    if context.cardarea == G.hand then
                        local ret_val = GE:card_effect(self, context, "hand_repetition_end_round")
                        if ret_val then return ret_val end
                    end
                elseif not context.blueprint then
                    local ret_val = GE:card_effect(self, context, "end_round")
                    if ret_val then return ret_val end
                end
            elseif context.individual then
                if context.cardarea == G.play then
                    local ret_val = GE:card_effect(self, context, "play_individual")
                    if ret_val then return ret_val end
                end
                if context.cardarea == G.hand then
                    local ret_val = GE:card_effect(self, context, "hand_individual")
                    if ret_val then return ret_val end
                end
            elseif context.repetition then
                if context.cardarea == G.play then
                    local ret_val = GE:card_effect(self, context, "play_repetition")
                    if ret_val then return ret_val end
                end
                if context.cardarea == G.hand then
                    local ret_val = GE:card_effect(self, context, "hand_repetition")
                    if ret_val then return ret_val end
                end
            elseif context.other_joker then
                local ret_val = GE:card_effect(self, context, "other_joker")
                if ret_val then return ret_val end
            else
                if context.cardarea == G.jokers then
                    if context.before then
                        local ret_val = GE:card_effect(self, context, "pre_joker")
                        if ret_val then return ret_val end
                    elseif context.after then
                        local ret_val = GE:card_effect(self, context, "post_joker")
                        if ret_val then return ret_val end
                    else
                        local ret_val = GE:card_effect(self, context, "joker")
                        if ret_val then return ret_val end
                    end
                end
            end
        end
    ]])
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

function GE:card_effect(self, context, context_name)
    if self.ability then
        for k, v in pairs(GE.items) do
            for k, v in pairs(v) do
                if v.data.abilities and v.pool == self.ability.set and v.data.name == self.ability.name then
                    for k, v in pairs(v.data.abilities) do
                        if k == context_name then
                            return v(self, context);
                        end
                    end
                end
            end
        end
    end
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

    local localization = love.filesystem.getInfo('localization/'..G.SETTINGS.language..'.lua')
    if localization ~= nil then
      self.localization = assert(loadstring(love.filesystem.read('localization/'..G.SETTINGS.language..'.lua')))()
      init_localization();
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
        local i = 0
        for k, v2 in pairs(G.P_CENTER_POOLS[v.pool]) do
            if v.data.name == v2.name then
                i = k;
                break;
            end
        end
        G.P_CENTER_POOLS[v.pool][i] = nil;
        i = 0;
        for k, v2 in pairs(G.P_JOKER_RARITY_POOLS[v.data.rarity]) do
            if v.data.name == v2.name then
                i = k;
                break;
            end
        end
        if i ~= 0 then
            G.P_JOKER_RARITY_POOLS[v.data.rarity][i] = nil;
        end
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