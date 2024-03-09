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

function Passport_Joker()
    GE:add_item(MOD_ID, "Joker", "j_passport", {
        rarity = 3,
        cost = 8,
        name = "Passport Joker",
        set = "Joker",
        config = {
        },
        loc_var_func = function(card) 
            local other_joker = nil
            if G.jokers then
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i+1] end
                end
                if other_joker and other_joker ~= card then
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
        version = "0.1",
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
            GE:refresh_items()
        end,

        on_disable = function()
            GE:disable(MOD_ID)
        end,
    }
)