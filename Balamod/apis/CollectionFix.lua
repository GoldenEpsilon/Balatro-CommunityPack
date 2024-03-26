function create_UIBox_your_collection_generic(pool, rows, cols, rowoffset, spawnfunc, w, h, padding)
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, rows do
        G.your_collection[j] = CardArea(
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
            (w + (rowoffset and (j + 1) % 2 or 0)) * G.CARD_W,
            h * G.CARD_H,
            { card_limit = cols + (rowoffset and (j + 1) % 2 or 0), type = 'title', highlight_limit = 0, collection = true })
        table.insert(deck_tables,
            {
                n = G.UIT.R,
                config = { align = "cm", padding = padding, no_fill = true },
                nodes = {
                    { n = G.UIT.O, config = { object = G.your_collection[j] } }
                }
            }
        )
    end

    local options = {}
    local pages = math.ceil(#G.P_CENTER_POOLS[pool] / (cols * #G.your_collection + (rowoffset and #G.your_collection / 2 or 0)))
    for i = 1, pages do
        table.insert(options, localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(pages))
    end

    G.FUNCS["your_collection_" .. pool] = (function(args)
        if not args or not args.cycle_config then return end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards, 1, -1 do
                local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                c:remove()
                c = nil
            end
        end
        for j = 1, #G.your_collection do
            for i = 1, cols + (rowoffset and (j + 1) % 2 or 0) do
                local center = G.P_CENTER_POOLS[pool][i + 
                    (j - 1) * cols + (cols * (#G.your_collection) * (args.cycle_config.current_option - 1)) + 
                    (rowoffset and #G.your_collection / 2 or 0) * (args.cycle_config.current_option - 1)]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y,
                    G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
                spawnfunc(card, center, i, j)
                G.your_collection[j]:emplace(card)
            end
        end
        INIT_COLLECTION_CARD_ALERTS()
    end);

    G.FUNCS["your_collection_" .. pool]({ cycle_config = { current_option = 1 } });

    local t = create_UIBox_generic_options({
        back_func = 'your_collection',
        contents = {
            { n = G.UIT.R, config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 }, nodes = deck_tables },
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    create_option_cycle({ options = options, w = 4.5, cycle_shoulders = true, opt_callback =
                    "your_collection_" .. pool, current_option = 1, colour = G.C.RED, no_pips = true, focus_args = { snap_to = true, nav = 'wide' } })
                }
            }
        }
    })
    return t
end

table.insert(mods,
    {
        mod_id = "collection_fix",
        name = "CollectionFix",
        author = "Golden Epsilon",
        version = "0.1",
        description = {
            "Fixes the collection screens",
            "To have the right number of pages",
        },
        enabled = true,
        on_enable = function()
            -- You know, I'm normally all for hooking and wrapping and non-destructive modding.
            -- For the collection functions, though? No, this original code does not need to stay.
            -- By the way, the if(true) is because lua doesn't like code after returns
            injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_jokers", [[
                if(true) then
                    return create_UIBox_your_collection_generic("Joker", 3, 5, false, function(card, center, i, j) card.sticker = get_joker_win_sticker(center) end, 5, 0.95, 0.07);
                end
            ]])
            injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_tarots", [[
                if(true) then
                    return create_UIBox_your_collection_generic("Tarot", 2, 5, true, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 5.25, 1, 0);
                end
            ]])
            --[=[injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_boosters", [[
                if(true) then
                    return create_UIBox_your_collection_generic("Booster", 2, 4, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 5.25, 1.3, 0);
                end
            ]])]=]
            injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_planets", [[
                if(true) then
                    return create_UIBox_your_collection_generic("Planet", 2, 6, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 6.25, 1, 0);
                end
            ]])
            injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_spectrals", [[
                if(true) then
                    return create_UIBox_your_collection_generic("Spectral", 2, 4, true, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 4.25, 1, 0);
                end
            ]])
            --injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_vouchers", [[
            --    if(true) then
            --        return create_UIBox_your_collection_generic("Voucher", 2, 4, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 4.25, 1, 0);
            --    end
            --]])
            --injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_seals", [[
            --    return create_UIBox_your_collection_generic("Seal", 2, 4, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 4.25, 1.03, 0);
            --]])
            injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_enhancements", [[
                if(true) then
                    return create_UIBox_your_collection_generic("Enhanced", 2, 4, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 4.25, 1.03, 0);
                end
            ]])
            --injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_editions", [[
            --    return create_UIBox_your_collection_generic("Enhanced", 2, 4, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 4.25, 1, 0);
            --]])
            --injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_decks", [[
            --    return create_UIBox_your_collection_generic("Enhanced", 2, 4, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 4.25, 1, 0);
            --]])
            --injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_tags", [[
            --    return create_UIBox_your_collection_generic("Enhanced", 2, 4, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 4.25, 1, 0);
            --]])
            --injectHead("functions/UI_definitions.lua", "create_UIBox_your_collection_blinds", [[
            --    return create_UIBox_your_collection_generic("Enhanced", 2, 4, false, function(card, center, i, j) card:start_materialize(nil, i > 1 or j > 1) end, 4.25, 1, 0);
            --]])
        end
    }
)