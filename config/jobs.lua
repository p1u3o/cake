Config.Jobs = {
    ["unemployed"] = 
    {
        Name = "Unemployed",
        Offduty = false,
        Emergency = false,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Unemployed",
                Pay = Config.UniversalIncome
            }
        },
    },

    ["police"] = 
    {
        Name = "Police",
        Offduty = true,
        Emergency = true,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Recruit",
                Pay = 185
            },
            [1] = {
                Title = "Cadet",
                Pay = 200
            },
            [2] = {
                Title = "Officer / Deputy",
                Pay = 225
            },           
            [3] = {
                Title = "Senior",
                Pay = 245
            },     
            [4] = {
                Title = "Corporal",
                Pay = 265
            },    
            [5] = {
                Title = "Sergeant",
                Pay = 285
            },  
            [6] = {
                Title = "Lieutenant",
                Pay = 305
            },  
            [7] = {
                Title = "Captain / Sheriff",
                Pay = 325
            },  
            [8] = {
                Title = "Chief of Police",
                Pay = 345
            },  
        },
        Permissions = {
            "policejob.reply"
        }
    },

    ["ambulance"] = 
    {
        Name = "SAMS",
        Offduty = true,
        Emergency = true,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Trainee Paramedic",
                Pay = 205
            },
            [1] = {
                Title = "Junior Paramedic",
                Pay = 225
            },
            [2] = {
                Title = "Paramedic",
                Pay = 245
            },           
            [3] = {
                Title = "Senior Paramedic",
                Pay = 265
            },     
            [4] = {
                Title = "Medical Director",
                Pay = 285
            },    
            [5] = {
                Title = "Chief of Medicine",
                Pay = 305
            },  
            [6] = {
                Title = "Deputy Chief",
                Pay = 325
            },  
            [7] = {
                Title = "Chief",
                Pay = 345
            },   
        },
    },

    ["cardealer"] = 
    {
        Name = "Sunrise Autos",
        Offduty = true,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Recruit",
                Pay = 125
            },
            [1] = {
                Title = "Salesman",
                Pay = 145
            },
            [2] = {
                Title = "Experienced Salesman",
                Pay = 165
            },           
            [3] = {
                Title = "Manager",
                Pay = 185
            },     
            [4] = {
                Title = "Boss",
                Pay = 205
            },    
        },
    },

    ["pdm"] = 
    {
        Name = "PDM",
        Offduty = true,
        Emergency = false,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Recruit",
                Pay = 125
            },
            [1] = {
                Title = "Salesman",
                Pay = 145
            },
            [2] = {
                Title = "Experienced Salesman",
                Pay = 165
            },           
            [3] = {
                Title = "Manager",
                Pay = 185
            },     
            [4] = {
                Title = "Boss",
                Pay = 205
            },    
        },
    },

    ["weazel"] = 
    {
        Name = "Weazel News",
        Offduty = true,
        Emergency = false,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Intern",
                Pay = 135
            },
            [1] = {
                Title = "Junior Editor",
                Pay = 155
            },
            [2] = {
                Title = "Editor",
                Pay = 175
            },           
            [3] = {
                Title = "Senior Editor",
                Pay = 195
            },     
            [4] = {
                Title = "Chief Editor",
                Pay = 215
            },    
            [5] = {
                Title = "Chief Business Officer",
                Pay = 225
            }, 
            [6] = {
                Title = "Chief Executive Officer",
                Pay = 235
            }, 
        },
    },

    ["attorney"] = 
    {
        Name = "City Hall",
        Offduty = true,
        Emergency = true,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Private Lawyer",
                Pay = 125
            },
            [1] = {
                Title = "Attorney",
                Pay = 160
            },
            [2] = {
                Title = "Department Head",
                Pay = 180
            },           
            [3] = {
                Title = "Executive",
                Pay = 200
            },     
            [4] = {
                Title = "Attorney General",
                Pay = 220
            },    
            [5] = {
                Title = "Mayor",
                Pay = 240
            }, 
        },
    },

    ["mechanic"] = 
    {
        Name = "Bennys Mechanics",
        Offduty = true,
        Emergency = false,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Recruit",
                Pay = 125
            },
            [1] = {
                Title = "Mechanic",
                Pay = 150
            },
            [2] = {
                Title = "Experienced",
                Pay = 175
            },           
            [3] = {
                Title = "Chief",
                Pay = 200
            },     
            [4] = {
                Title = "Boss",
                Pay = 225
            },    
        },
    },

    ["realestate"] = 
    {
        Name = "Real Estate",
        Offduty = true,
        Emergency = false,
        SocietyPay = true,
        Grades = {
            [0] = {
                Title = "Business",
                Pay = 125
            },
            [1] = {
                Title = "Trainee",
                Pay = 125
            },
            [2] = {
                Title = "Agent",
                Pay = 150
            },           
            [3] = {
                Title = "Broker",
                Pay = 200
            },     
            [4] = {
                Title = "Manager",
                Pay = 220
            },    
            [5] = {
                Title = "CEO",
                Pay = 240
            },  
        },
    },
}