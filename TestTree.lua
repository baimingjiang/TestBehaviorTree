local testStr = 
[===[
SEL:小怪AI
    SEQ:是否巡逻
        1. CON:视野没有敌人:hasEnemyInView:false
        2. ACT:左右看看:watchRound
		3. ACT:开始巡逻:goOnPatrol
	SEL:攻击敌人
		SEL:攻击敌人
			SEQ:跑向敌人
				1. CON:没有在攻击范围:hasNotEnemyInAttackRange
				2. ACT:向前跑:goToEnemy 
            SEQ:开始释放技能
                1. CON:打的过:isBigBoss:100
				2. CON:可以释放大招:canReleaseSkill
				3. ACT:释放必杀技:releaseSkill
		SEQ:回到阵营
			ACT:往回走:goHome 
]===]


local tree = {
    level = 1,
    name = "小怪AI",
    bttype = "SEL",
    children = {
        [1] = {
            level = 2,
            name = "是否巡逻",
            bttype = "SEQ",
            children = {
                [1] = {
                    name = "左右看看",
                    bttype = "ACT",
                    level = 3,
                    fun = "watchRound",
                },
                [2] = {
                    name = "视野没有敌人",
                    bttype = "CON",
                    level = 3,
                    fun = "hasEnemyInView",
                    param = false,
                },
                
                [3] = {
                    name = "开始来回走动",
                    bttype = "ACT",
                    level = 3,
                    fun = "goOnPatrol",
                }
            }
        },
        [2] = {
            level = 2,
            name = "是否攻击敌人",
            bttype = "SEQ",
            children = {
                [1] = {
                    level = 3,
                    name = "攻击敌人",
                    bttype = "SEL", 
                    children = {
                        [1] = {
                            level = 4,
                            name = "是否需要跑向敌人",
                            bttype = "SEQ", 
                            children = {
                                [1] = {
                                    level = 5,
                                    name = "没有在攻击范围",
                                    bttype = "CON", 
                                    fun = "hasNotEnemyInAttackRange",
                                },
                                [2] = {
                                    level = 5,
                                    name = "跑向敌人",
                                    bttype = "ACT", 
                                    fun = "goToEnemy",
                                }
                            }
                        },
                        [2] = {
                            level = 4,
                            name = "开始释放技能",
                            bttype = "SEQ", 
                            children = {
                                [1] = {
                                    level = 5,
                                    name = "是否打的过",
                                    bttype = "CON", 
                                    fun = "isBigBoss",
                                    param = 100
                                },
                                [2] = {
                                    level = 5,
                                    name = "可以释放大招",
                                    bttype = "CON", 
                                    fun = "canReleaseSkill",
                                },
                                [3] = {
                                    level = 5,
                                    name = "释放大招",
                                    bttype = "ACT", 
                                    fun = "releaseSkill",
                                }
                            }
                        }
                    }
                },
                [2] = {
                    level = 3,
                    name = "返回营地",
                    bttype = "ACT",
                    fun = "goHome" 
                },
            }
        },
    }
}

return tree