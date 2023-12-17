
Cake.ORM = {}
Cake.ORM.Models = 
{
    -- Users --
    ["users"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "owner",
                Type = "int",
                Extra = "",
                Default = 0
            },
            {
                Name = "uuid",
                Type = "varchar(36)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "firstname",
                Type = "varchar(50)",
                Extra = "NOT NULL",
                Default = ""
            },
            {
                Name = "lastname",
                Type = "varchar(50)",
                Extra = "NOT NULL",
                Default = ""
            },
            {
                Name = "job",
                Type = "varchar(32)",
                Extra = "NOT NULL",
                Default = "unemployed"
            },
            {
                Name = "job_grade",
                Type = "int(12)",
                Extra = "NOT NULL",
                Default = 0,
            },
            {
                Name = "is_dead",
                Type = "tinyint(1)",
                Extra = "NOT NULL",
                Default = 0,
            },
            {
                Name = "phone_number",
                Type = "varchar(10)",
                Extra = "",
                Default = "NULL",
            },
            {
                Name = "jail",
                Type = "int(11)",
                Extra = "NOT NULL",
                Default = 0,
            },
            {
                Name = "deleted_at",
                Type = "int(10)",
                Extra = "NOT NULL",
                Default = 0,
            },
            {
                Name = "personal_spawn",
                Type = "varchar(155)",
                Extra = "",
                Default = 'NULL',
            },
            {
                Name = "bank",
                Type = "int(11)",
                Extra = "NOT NULL",
                Default = 0,
            },
        },
        Indexes = 
        {
            ["uuid"] = 
            {
                "uuid",
            },
            ["job"] = 
            {
                "job",
            },
        }
    },

    ["account"] = 
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "identifier",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = "0"
            },
            {
                Name = "name",
                Type = "text",
                Extra = "NOT NULL",
                Default = ""
            },
            {
                Name = "group",
                Type = "varchar(64)",
                Extra = "NOT NULL",
                Default = Config.DefaultGroup
            },
            {
                Name = "created_at",
                Type = "timestamp",
                Extra = "",
                Default = "current_timestamp()"
            },
            {
                Name = "migrated",
                Type = "int",
                Extra = "",
                Default = 0
            },
            {
                Name = "online_time",
                Type = "int",
                Extra = "",
                Default = 0
            },
            {
                Name = "last_connected",
                Type = "timestamp",
                Extra = "",
                Default = "current_timestamp()",
                OnUpdate = "current_timestamp()"
            },
        },
        Indexes = 
        {
            ["identifier"] = 
            {
                "identifier",
            },
        }
    },

    ["baninfo"] = 
    {
        PrimaryKey = "identifier",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "identifier",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "steam",
                Type = "varchar(64)",
                Extra = "",
                Default = nil
            },
            {
                Name = "license",
                Type = "varchar(64)",
                Extra = "",
                Default = nil
            },
            {
                Name = "liveid",
                Type = "varchar(64)",
                Extra = "",
                Default = nil
            },
            {
                Name = "xblid",
                Type = "varchar(64)",
                Extra = "",
                Default = nil
            },
            {
                Name = "discord",
                Type = "varchar(64)",
                Extra = "",
                Default = nil
            },
            {
                Name = "playerip",
                Type = "varchar(64)",
                Extra = "",
                Default = nil
            },
            {
                Name = "playername",
                Type = "varchar(64)",
                Extra = "",
                Default = nil
            },
            {
                Name = "hwid",
                Type = "varchar(512)",
                Extra = "",
                Default = 'no info'
            },
        }
    },

    -- Crews
    ["crews"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "crew",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "type",
                Type = "varchar(32)",
                Extra = "NOT NULL",
                Default = nil
            },
        }
    },

    ["crews_members"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "crew",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "uuid",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "grade",
                Type = "int",
                Extra = "",
                Default = 0
            },
            {
                Name = "is_active",
                Type = "int(2)",
                Extra = "",
                Default = 0
            },
        }
    },

    -- Experience --
    ["experience"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "uuid",
                Type = "varchar(32)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "name",
                Type = "varchar(64)",
                Extra = "NOT NULL",
                Default = ""
            },
            {
                Name = "experience",
                Type = "int",
                Extra = "NOT NULL",
                Default = 0
            },
        },
        Indexes = 
        {
            ["uuid"] = 
            {
                "uuid",
                "name"
            }
        }
    },
    
    -- Boxing --
    ["boxing_board"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "uuid",
                Type = "varchar(32)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "name",
                Type = "varchar(64)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "score",
                Type = "int",
                Extra = "NOT NULL",
                Default = 0
            },
        }
    },

    -- Cars --
    ["owned_vehicles"] =
    {
        PrimaryKey = "plate",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "plate",
                Type = "varchar(12)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "transferable",
                Type = "int",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "owner",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "vehicle",
                Type = "longtext",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "state",
                Type = "tinyint(1)",
                Extra = "NOT NULL",
                Default = 0
            },
            {
                Name = "impound",
                Type = "tinyint(1)",
                Extra = "NOT NULL",
                Default = 0
            },
            {
                Name = "garage",
                Type = "varchar(200)",
                Extra = "NOT NULL",
                Default = "A"
            },
            {
                Name = "model",
                Type = "varchar(200)",
                Extra = "NOT NULL",
                Default = ""
            },
        }
    },

    -- CAD --
    ["granite_impounds"] =
    {
        PrimaryKey = "plate",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "plate",
                Type = "varchar(8)",
                Extra = "NOT NULL",
                Default = ""
            },
            {
                Name = "charges",
                Type = "text",
                Extra = "NOT NULL",
                Default = ""
            },
            {
                Name = "fine",
                Type = "int(11)",
                Extra = "NOT NULL",
                Default = 0
            },
            {
                Name = "report",
                Type = "longtext",
                Extra = "NOT NULL",
                Default = ""
            },
            {
                Name = "author",
                Type = "varchar(50)",
                Extra = "NOT NULL",
                Default = ""
            },
            {
                Name = "hold",
                Type = "int(50)",
                Extra = "NOT NULL",
                Default = 0
            },
        }
    },

    -- Appearance
    ["character_current"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int(8)",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "identifier",
                Type = "varchar(128)",
                Extra = "",
                Default = nil
            },
            {
                Name = "model",
                Type = "varchar(128)",
                Extra = "",
                Default = nil
            },
            {
                Name = "drawables",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "props",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "drawtextures",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "proptextures",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
        }
    },

    ["character_face"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int(8)",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "identifier",
                Type = "varchar(128)",
                Extra = "",
                Default = nil
            },
            {
                Name = "hairColor",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "headBlend",
                Type = "varchar(255)",
                Extra = "",
                Default = nil
            },
            {
                Name = "headOverlay",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "headStructure",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
        }
    },

    ["character_tattoos"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int(8)",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "identifier",
                Type = "varchar(128)",
                Extra = "",
                Default = nil
            },
            {
                Name = "tattoos",
                Type = "varchar(255)",
                Extra = "",
                Default = "{}"
            },
        }
    },

    ["character_outfits"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int(8)",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "identifier",
                Type = "varchar(128)",
                Extra = "",
                Default = nil
            },
            {
                Name = "name",
                Type = "varchar(255)",
                Extra = "",
                Default = nil
            },
            {
                Name = "slot",
                Type = "varchar(32)",
                Extra = "",
                Default = nil
            },
            {
                Name = "model",
                Type = "varchar(32)",
                Extra = "",
                Default = nil
            },
            {
                Name = "drawables",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "props",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "drawtextures",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "propTextures",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
            {
                Name = "hairColor",
                Type = "longtext",
                Extra = "",
                Default = nil
            },
        }
    },

    ["outfit_codes"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int(11)",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "character",
                Type = "varchar(128)",
                Extra = "",
                Default = nil
            },
        }
    },
        
    ["society"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "int(32)",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "account_name",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "money",
                Type = "int(32)",
                Extra = "",
                Default = 100
            },
            {
                Name = "owner",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
        }
    },

    -- Inventory
    ["inventory"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "bigint",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "owner",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "type",
                Type = "varchar(128)",
                Extra = "",
                Default = nil
            },
            {
                Name = "data",
                Type = "longtext",
                Extra = "NOT NULL",
                Default = nil
            },
        },
        Indexes = 
        {
            ["inventory"] = 
            {
                "owner",
                "type"
            }
        }
    },

    ["inventory_weapons"] =
    {
        PrimaryKey = "id",
        SoftDeletes = false,
        Columns = 
        {
            {
                Name = "id",
                Type = "bigint",
                Extra = "NOT NULL AUTO_INCREMENT",
                Default = nil
            },
            {
                Name = "serial",
                Type = "varchar(128)",
                Extra = "",
                Default = ""
            },
            {
                Name = "owner",
                Type = "varchar(128)",
                Extra = "",
                Default = ""
            },
            {
                Name = "weapon",
                Type = "varchar(128)",
                Extra = "NOT NULL",
                Default = nil
            },
            {
                Name = "date",
                Type = "bigint(20)",
                Extra = "",
                Default = 0
            },
            {
                Name = "source",
                Type = "varchar(256)",
                Extra = "",
                Default = 0
            },
            {
                Name = "registered",
                Type = "tinyint",
                Extra = "",
                Default = 0
            },
        },
        Indexes = 
        {
            ["serial"] = 
            {
                "serial",
            }
        }
    },
}