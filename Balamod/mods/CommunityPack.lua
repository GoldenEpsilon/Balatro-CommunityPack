local MOD_ID = "CommunityPack";

function UltimAce()
    GE:add_item(MOD_ID, "Joker", "j_ultimace", {
        rarity = 3,
        cost = 8,
        name = "UltimAce",
        set = "Joker",
        config = {
            extra = 1;
        }
    },{
        name = "UltimAce",
        text = {
            "When an {C:attention}Enhanced Ace{} is scored,",
            "Retrigger it"
        }
    });


    injectHead("card.lua", "Card:calculate_joker", [[
        if self.ability.set == "Joker" and not self.debuff then
            if context.repetition then
                if context.cardarea == G.play then
                    if self.ability.name == 'UltimAce' and context.other_card.ability then
                        return {
                            message = localize('k_again_ex'),
                            repetitions = self.ability.extra,
                            card = self
                        }
                    end
                end
            end
        end
    ]])
end

function Baba()
    GE:add_item(MOD_ID, "Joker", "j_baba", {
        rarity = 3,
        cost = 5,
        name = "Baba",
        set = "Joker",
        config = {
            extra = {
                x_mult = 3,
                type1 = "Pair",
                type2 = "High Card"
            }
        },
        loc_var_func = function(self) return {self.ability.extra.x_mult, self.ability.extra.type1, self.ability.extra.type2} end
    },{
        name = "Baba",
        text = {
            "Gives {X:red,C:white} X#1# {} Mult if played hand is a",
            "{C:attention}#2#{} or {C:attention}#3#{}"
        }
    });


    injectHead("card.lua", "Card:calculate_joker", [[
        if self.ability.set == "Joker" and not self.debuff then
            if context.cardarea == G.jokers then
                if not context.before and not context.after then
                    if self.ability.name == 'Baba' and context.poker_hands then
                        local baba = true;
                        for k, v in pairs(context.poker_hands) do
                            if k ~= "top" and next(v) and k ~= self.ability.extra.type1 and k ~= self.ability.extra.type2 then
                                baba = false
                            end
                        end
                        if baba then
                            return {
                                message = localize{type='variable',key='a_xmult',vars={self.ability.extra.x_mult}},
                                colour = G.C.RED,
                                Xmult_mod = self.ability.extra.x_mult
                            }
                        end
                    end
                end
            end
        end
    ]])
end

function Missing_Texture()
    GE:add_item(MOD_ID, "Joker", "j_missingtexture", {
        rarity = 2,
        cost = 5,
        name = "Missing Texture",
        set = "Joker",
        config = {
            extra = {
            }
        },
        loc_var_func = function(self) return {} end,
        abilities = {
            pre_joker = function(self, context)
                if next(context.poker_hands["Pair"]) then
                    context.poker_hands["Four of a Kind"] = context.poker_hands["Pair"];
                end
            end,
        }
    },{
        name = "Missing Texture",
        text = {
            "{C:attention}Two Pair{} counts as",
            "{C:attention}Four Of A Kind{}"
        }
    });
end

function Background_Joker()
    GE:add_item(MOD_ID, "Joker", "j_background", {
        rarity = 2,
        cost = 5,
        name = "Background",
        set = "Joker",
        config = {
            extra = {
            }
        },
        loc_var_func = function(self) return {} end,
        abilities = {
            joker = function(self, context)
                local ret_val = -1;
                for k, v in pairs(context.poker_hands) do
                    if next(v) then ret_val = ret_val + 1 end
                end
                if ret_val < 0 then ret_val = 0 end
                if next(context.poker_hands["Pair"]) then
                    context.poker_hands["Four of a Kind"] = context.poker_hands["Pair"];
                end
                return {
                    message = localize{type='variable',key='a_mult',vars={ret_val * ret_val}},
                    mult_mod = ret_val * ret_val
                }
            end,
        }
    },{
        name = "Background",
        text = {
            "Give mult equal the square of",
            "the number of hands",
            "that can be made out of your scored cards"
        }
    });
end

function Inverted_Joker()
    GE:add_item(MOD_ID, "Joker", "j_inverted", {
        rarity = 3,
        cost = 5,
        name = "Inverted Joker",
        set = "Joker",
        config = {
            extra = 3
        },
        loc_var_func = function(self) return {} end,
        abilities = {
            init = function(self)
                self.ability.invert_rounds = 0;
            end,
            sell_self = function(self, context)
                if self.ability.invert_rounds >= self.ability.extra then
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            add_tag(Tag('tag_negative'))
                            play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                            play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                            return true
                        end)
                    }))
                end
            end,
            end_round = function(self, context)
                self.ability.invert_rounds = self.ability.invert_rounds + 1
                if self.ability.invert_rounds == self.ability.extra then 
                    local eval = function(card) return not card.REMOVED end
                    juice_card_until(self, eval, true)
                end
                return {
                    message = (self.ability.invert_rounds < self.ability.extra) and (self.ability.invert_rounds..'/'..self.ability.extra) or localize('k_active_ex'),
                    colour = G.C.FILTER
                }
            end
        }
    },{
        name = "Inverted Joker",
        text = {
            "After 3 rounds,",
            "sell this to gain ",
            "a free {C:attention}Negative Tag{}"
        }
    });
end

function Free_Sample()
    GE:add_item(MOD_ID, "Joker", "j_freesample", {
        rarity = 1,
        cost = 4,
        name = "Free Sample",
        set = "Joker",
        config = {
            extra = {
                hands = 1
            }
        },
        loc_var_func = function(self) return {self.ability.free_sample_poker_hand} end,
        abilities = {
            init = function (self)
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then _poker_hands[#_poker_hands+1] = k end
                end
                local old_hand = self.ability.free_sample_poker_hand
                self.ability.free_sample_poker_hand = nil

                while not self.ability.free_sample_poker_hand do
                    self.ability.free_sample_poker_hand = pseudorandom_element(_poker_hands, pseudoseed((self.area and self.area.config.type == 'title') and 'false_freesample' or 'freesample'))
                    if self.ability.free_sample_poker_hand == old_hand then self.ability.free_sample_poker_hand = nil end
                end
            end,

            post_joker = function(self, context) 
                if context.scoring_name == self.ability.free_sample_poker_hand then
                    G.E_MANAGER:add_event(Event({func = function()
                        ease_hands_played(self.ability.extra.hands)
                        card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_hands', vars = {self.ability.extra.hands}}})
                    return true end }))
                end
                
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then _poker_hands[#_poker_hands+1] = k end
                end
                local old_hand = self.ability.free_sample_poker_hand
                self.ability.free_sample_poker_hand = nil

                while not self.ability.free_sample_poker_hand do
                    self.ability.free_sample_poker_hand = pseudorandom_element(_poker_hands, pseudoseed((self.area and self.area.config.type == 'title') and 'false_freesample' or 'freesample'))
                    if self.ability.free_sample_poker_hand == old_hand then self.ability.free_sample_poker_hand = nil end
                end
            end
        }
    },{
        name = "Free Sample",
        text = {
            "+1 hand if poker hand is a {C:attention}#1#{}",
            "Poker hand changes every hand"
        }
    });
end

function Not_Found()
    GE:add_item(MOD_ID, "Joker", "j_notfound", {
        rarity = 1,
        cost = 4,
        name = "Joker Not Found",
        set = "Joker",
        config = {
            extra = {
                chip_mod = 404,
                odds = 4
            }
        },
        loc_var_func = function(self) return {G.GAME.probabilities.normal, self.ability.extra.odds, self.ability.extra.chip_mod} end,
        abilities = {
            joker = function(self, context) 
                if pseudorandom('notfound') < G.GAME.probabilities.normal/self.ability.extra.odds then
                    return {
                        message = localize{type='variable',key='a_chips',vars={self.ability.extra.chip_mod}},
                        chip_mod = self.ability.extra.chip_mod,
                    }
                end
            end
        }
    },{
        name = "Joker Not Found",
        text = {
            "{C:attention}#1#{} in {C:attention}#2#{} chance to add {C:chips}#3#{} chips" -- should be set chips to 404, but that's hard to do
        }
    });
    
    -- Inject doesn't work on this function yet...
    --GE:inject(MOD_ID, "functions/state_events.lua", "G.FUNCS.evaluate_play", "if effects.jokers.chip_mod then hand_chips = mod_chips(hand_chips + effects.jokers.chip_mod);extras.hand_chips = true end", 
    -- [[if effects.jokers.chip_mod then hand_chips = mod_chips(hand_chips + effects.jokers.chip_mod);extras.hand_chips = true end
    --if effects.jokers.chip_set_mod then hand_chips = mod_chips(effects.jokers.chip_set_mod);extras.hand_chips = true end]]);
    
end

function Executioner()
    GE:add_item(MOD_ID, "Joker", "j_executioner", {
        rarity = 3,
        cost = 8,
        name = "Executioner",
        set = "Joker",
        config = {
        },
        loc_var_func = function(self) return {self.ability.executioner_poker_hand} end,
        abilities = {
            init = function (self)
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then _poker_hands[#_poker_hands+1] = k end
                end
                local old_hand = self.ability.executioner_poker_hand
                self.ability.executioner_poker_hand = nil

                while not self.ability.executioner_poker_hand do
                    self.ability.executioner_poker_hand = pseudorandom_element(_poker_hands, pseudoseed((self.area and self.area.config.type == 'title') and 'false_executioner' or 'executioner'))
                    if self.ability.executioner_poker_hand == old_hand then self.ability.executioner_poker_hand = nil end
                end
            end,
            end_round = function (self)
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then _poker_hands[#_poker_hands+1] = k end
                end
                local old_hand = self.ability.executioner_poker_hand
                self.ability.executioner_poker_hand = nil

                while not self.ability.executioner_poker_hand do
                    self.ability.executioner_poker_hand = pseudorandom_element(_poker_hands, pseudoseed((self.area and self.area.config.type == 'title') and 'false_executioner' or 'executioner'))
                    if self.ability.executioner_poker_hand == old_hand then self.ability.executioner_poker_hand = nil end
                end
            end,
            start_round = function(self, context) 
                if not context.blueprint then
                    local eval = function() return G.GAME.current_round.hands_played == 0 end
                    juice_card_until(self, eval, true)
                end
            end,
            post_joker = function (self, context)
                if G.GAME.current_round.hands_played == 0 and context.scoring_name == self.ability.executioner_poker_hand then
                    local destroyed_cards = {}
                    for i=1, #context.scoring_hand do
                        destroyed_cards[#destroyed_cards + 1] = context.scoring_hand[i]
                        if context.scoring_hand[i].ability.name == 'Glass Card' then 
                            context.scoring_hand[i]:shatter()
                        else
                            context.scoring_hand[i]:start_dissolve()
                        end
                    end
                    if destroyed_cards[1] then 
                        for j=1, #G.jokers.cards do
                            eval_card(G.jokers.cards[j], {cardarea = G.jokers, remove_playing_cards = true, removed = destroyed_cards})
                        end
                    end
                    return 
                    {
                        message = "Executed!",
                        colour = G.C.FILTER,
                        delay = 0.45, 
                        card = self
                    }
                end
            end
        }
    },{
        name = "Executioner",
        text = {
            "If first played poker hand of the round is a {C:attention}#1#{},",
            "destroy all cards scored in it.",
            "Poker hand changes every round"
        }
    });
end

function Passport_Joker()
    GE:add_item(MOD_ID, "Joker", "j_passport", {
        rarity = 3,
        cost = 8,
        name = "Passport Joker",
        set = "Joker",
        config = {
        },
        loc_var_func = function(self) 
            local other_joker = nil
            if G.jokers then
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == self then other_joker = G.jokers.cards[i+1] end
                end
                if other_joker and other_joker ~= self then
                    if ((other_joker.ability.t_chips or other_joker.ability.t_mult or other_joker.ability.x_mult) or
                    other_joker.ability.extra and (other_joker.extra.chip_mod or other_joker.extra.chips or other_joker.ability.extra.mult or other_joker.ability.extra.x_mult)) then
                        return {other_joker.ability.name .. " is compatible"} 
                    end
                    return {other_joker.ability.name .. " is not compatible"} 
                end
            end
            return {""}
        end
    },{
        name = "Passport Joker",
        text = {
            "gives benefits of joker to the right",
            "{C:attention}ignoring{} the condition",
            "{C:attention}#1#{}"
        }
    });
    injectHead("card.lua", "Card:calculate_joker", [[
        if self.ability.set == "Joker" and not self.debuff then
            if context.cardarea == G.jokers then
                if not context.before and not context.after then
                    if self.ability.name == 'Passport Joker' then
                        local other_joker = nil
                        for i = 1, #G.jokers.cards do
                            if G.jokers.cards[i] == self then other_joker = G.jokers.cards[i+1] end
                        end
                        if other_joker and other_joker ~= self then
                            local chips = 0;
                            local mult = 0;
                            local xmult = 1;
                            if other_joker.ability.t_chips then
                                chips = chips + other_joker.ability.t_chips;
                            end
                            if other_joker.ability.t_mult then
                                mult = mult + other_joker.ability.t_mult;
                            end
                            if other_joker.ability.x_mult > 1 then
                                xmult = other_joker.ability.x_mult;
                            end
                            if other_joker.ability.extra and other_joker.extra.chip_mod then
                                chips = chips + other_joker.extra.chip_mod;
                            end
                            if other_joker.ability.extra and other_joker.extra.chips then
                                chips = chips + other_joker.extra.chips;
                            end
                            if other_joker.ability.extra and other_joker.ability.extra.mult then
                                mult = mult + other_joker.ability.mult;
                            end
                            if other_joker.ability.extra and other_joker.ability.extra.x_mult then
                                xmult = other_joker.ability.extra.x_mult;
                            end
                            if chips > 0 or mult > 0 or xmult > 0 then
                                local message = "";
                                if chips > 0 then
                                    message = localize{type='variable',key='a_chips',vars={chips}}
                                else 
                                    chips = nil
                                end
                                if mult > 0 then
                                    if message then
                                        message = message .. "\n"
                                    end
                                    message = message .. localize{type='variable',key='a_mult',vars={mult}}
                                else 
                                    mult = nil
                                end
                                if xmult > 1 then
                                    if message then
                                        message = message .. "\n"
                                    end
                                    message = message .. localize{type='variable',key='a_xmult',vars={xmult}}
                                else 
                                    xmult = nil
                                end
                                return {
                                    message = message,
                                    colour = G.C.RED,
                                    chip_mod = chips,
                                    mult_mod = mult,
                                    Xmult_mod = xmult
                                }
                            end
                        end
                    end
                end
            end
        end
    ]])
end

table.insert(mods,
    {
        mod_id = "community_pack",
        name = "Community Joker Pack",
        author = "Golden Epsilon, Everyone!",
        version = "0.2",
        description = {
            "Adds custom jokers",
            "that were submitted",
            "in the discord!",
        },
        enabled = true,
        on_enable = function()
            GE:init()
            UltimAce()
            Passport_Joker()
            Not_Found()
            Free_Sample()
            Baba()
            Executioner()
            Missing_Texture()
            Inverted_Joker()
            Background_Joker()
            GE:refresh_items()
        end,

        on_disable = function()
            GE:disable(MOD_ID)
        end,
    }
)