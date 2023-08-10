local cfg = {}
local Skin_male = { model = wick }
--[[

  Component variations:
  0 - Face
  1 - Masks
  2 - Hair
  3 - Hands/Gloves
  4 - Legs
  5 - Bags
  6 - Shoes
  7 - Neck
  8 - Undershirts
  9 - Vest
  10 - Decals
  11 - Jackets

  
  Props variations:
  0 - Helmets, hats, earphones, masks
  1 - Glasses
  2 - Ear accessories

]]


cfg.uniforms = {

  ["Politia Romana"] = {
    faction = "Politia Romana",
    { -- male
     

      { rank = "Agent", props = {
        [0] = {-1},
        [1] = {-1},
      }, parts = {
        [11] = {306, 0},
        [4] = {105, 2},
        [6] = {10, 0},
        [9] = {20, 3},
        [8] = {4, 0},
        [1] = {153, 0},
      } },

      
      { rank = "Agent Sef Principal", props = {
        [0] = {-1},
        [1] = {-1},
      }, parts = {
        [11] = {306, 0},
        [4] = {105, 2},
        [6] = {10, 0},
        [9] = {9, 0},
        [8] = {4, 0},
        [1] = {153, 0},
      } },

      { rank = "Inspector", props = {
        [0] = {185, 0},
        [1] = {-1},
      }, parts = {
        [11] = {429, 8},
        [3] = {176, 0},
        [4] = {105, 0},
        [6] = {10, 0},
        [9] = {5, 0},
        [8] = {4, 0},
        [1] = {153, 0},
      } },

      { rank = "Sub-Comisar", props = {
        [0] = {185, 0},
        [1] = {-1},
      }, parts = {
        [11] = {449, 3},
        [3] = {176, 0},
        [4] = {112, 0},
        [6] = {90, 0},
        [9] = {5, 0},
        [8] = {4, 0},
        [1] = {153, 0},
      } },

      { rank = "Comisar", props = {
        [0] = {185, 0},
        [1] = {-1},
      }, parts = {
        [11] = {462, 3},
        [3] = {177, 0},
        [4] = {133, 0},
        [6] = {90, 0},
        [9] = {5, 0},
        [8] = {4, 0},
        [1] = {153, 0},
      } },

      { rank = "Comisar-Sef", props = {
        [0] = {185, 0},
        [1] = {-1},
      }, parts = {
        [11] = {18, 0},
        [3] = {176, 0},
        [4] = {112, 0},
        [6] = {90, 0},
        [7] = {1, 0},
        [9] = {5, 0},
        [8] = {178, 0},
        [1] = {153, 0},
      } },

      { rank = "D.I.I.C.O.T", props = {
        [0] = {185, 1},
        [1] = {-1},
      }, parts = {
        [11] = {12, 0},
        [3] = {178, 0},
        [4] = {112, 0},
        [6] = {90, 0},
        [7] = {1, 0},
        [9] = {1, 0},
        [8] = {178, 0},
        [1] = {158, 0},
      } },

      { rank = "Coordonator D.I.I.C.O.T", props = {
        [0] = {185, 1},
        [1] = {-1},
      }, parts = {
        [11] = {16, 0},
        [3] = {178, 0},
        [4] = {114, 0},
        [6] = {90, 0},
        [7] = {1, 0},
        [9] = {1, 0},
        [8] = {4, 1},
        [1] = {158, 0},
      } },

      { rank = "Moto", props = {
        [0] = {108, 0},
        [1] = {37, 2},
      }, parts = {
        [11] = {306, 0},
        [3] = {176, 0},
        [4] = {133, 0},
        [6] = {90, 0},
        [7] = {0, 0},
        [9] = {3, 0},
        [8] = {178, 0},
        [1] = {84, 0},
      } },

      { rank = "Femei", props = {
        [0] = {-1, 0},
        [1] = {44, 1},
      }, parts = {
        [11] = {11, 0},
        [8] = {1, 0},
        [9] = {1, 0},
        [3] = {3, 0},
        [4] = {72, 0},
        [6] = {130, 0},
        [1] = {00, 0},
      } },
    },

  },

  ["STAFF"] = {
	faction = "user",    
    { --
      { rank = "STAFF", props = {}, parts = {
        [11] = {7, 0},
        [8] = {-1, 0},
        [3] = {1, 0},
        [4] = {40, 0},
        [9] = {-1, 0},
        [6] = {16, 5},
        [1] = {0, 0},

      } },
    },
  },
    
    ["DIICOT"] = {
      faction = "DIICOT",
      { -- male
  
        { rank = "D.I.I.C.O.T", props = {
          [0] = {185, 1},
          [1] = {-1},
        }, parts = {
          [11] = {12, 0},
          [3] = {178, 0},
          [4] = {112, 0},
          [6] = {90, 0},
          [7] = {1, 0},
          [9] = {1, 0},
          [8] = {178, 0},
          [1] = {158, 0},
        } },
  
        { rank = "Coordonator D.I.I.C.O.T", props = {
          [0] = {185, 1},
          [1] = {-1},
        }, parts = {
          [11] = {16, 0},
          [3] = {178, 0},
          [4] = {114, 0},
          [6] = {90, 0},
          [7] = {1, 0},
          [9] = {1, 0},
          [8] = {4, 1},
          [1] = {158, 0},
        } },
  
        { rank = "Moto", props = {
          [0] = {108, 0},
          [1] = {37, 2},
        }, parts = {
          [11] = {306, 0},
          [3] = {176, 0},
          [4] = {133, 0},
          [6] = {90, 0},
          [7] = {0, 0},
          [9] = {3, 0},
          [8] = {178, 0},
          [1] = {84, 0},
        } },
      },

    { -- female
      { rank = "Femei", props = {}, parts = {
        [11] = {443, 0},
        [8] = {46, 0},
        [3] = {2, 0},
        [4] = {6, 0},
        [6] = {80, 0},
        [1] = {123, 0},
      } },
    },
  },

  ["Smurd"] = {
    faction = "Smurd",
    { -- male
      { rank = "Asistent Medical", parts = {
        [11] = {331, 19},
        [8] = {52, 0},
        [3] = {1, 0},
        [4] = {128, 4},
        [6] = {67, 0},
      } },

      { rank = "Medic Stagiar/Rezident", parts = {
        [11] = {5, 0},
        [8] = {15, 0},
        [3] = {85, 0},
        [4] = {1, 0},
        [6] = {90, 0},
        [7] = {231, 0},
        [5] = {92, 3},
        [10] = {0, 0},
      } },

      { rank = "Medic Specialist", parts = {
        [11] = {13, 0},
        [8] = {15, 0},
        [3] = {11, 2},
        [4] = {15, 0},
        [6] = {10, 0},
        [7] = {231, 0},
        [5] = {92, 3},
        [10] = {0, 0},
      } },

      { rank = "Medic Chirurg", parts = {
        [11] = {363, 1},
        [8] = {15, 0},
        [3] = {0, 0},
        [4] = {177, 1},
        [6] = {162, 0},
        [7] = {231, 0},
        [5] = {92, 3},
        [10] = {58, 0},
      } },

      { rank = "Medic Inspector", parts = {
        [11] = {13, 3},
        [8] = {15, 0},
        [3] = {11, 0},
        [4] = {10, 0},
        [6] = {86, 0},
        [7] = {231, 0},
        [5] = {92, 3},
        [10] = {0, 0},
      } },
    },
    
    { -- female
      { rank = "", props = {}, parts = {} },
    },
  }

}



cfg.cloakrooms = {
  {"Politia Romana", vec3(461.57424926758,-999.13806152344,30.689491271973), 90, {129, 188, 251}},
  {"STAFF", vec3(-169.11868286133,486.96914672852,137.44343566895), 90, {129, 188, 251}},
  {"Smurd", vec3(-823.94183349609,-1235.5358886719,7.3374261856079), 235, {194, 80, 80}},
  {"DIICOT", vec3(38.909194946289,-906.03820800781,29.90266418457), 235, {194, 80, 80}},
}

return cfg
