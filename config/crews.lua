Config.Crews = {
    Ranks = {"user", "senior", "manager", "owner"},
    Types = {
        ["gang"] = {
            Illegal = true,
            Social = true,
            Keys = true,
            Racing = false,
        },
        ["business"] = {
            Illegal = false,
            Social = true,
            Keys = true,
            Racing = false,
        },
        ["social"] = {
            Illegal = false,
            Social = true,
            Keys = false,
            Racing = false,
        },
        ["racer"] = {
            Illegal = false,
            Social = true,
            Keys = false,
            Racing = true,
        },
    }
}