local BehaviorTree = require("BehaviorTree")

local tree = require("TestTree")

local blackboard = {
    hasEnemyInView = true,
    bigBossValue = 100,
    canReleaseSkill = true,
    hasNotEnemyInAttackRange = false,
}

local entity = {
    hasEnemyInView = function(entity, param) 
        return blackboard.hasEnemyInView == param
    end,
    watchRound = function(entity, param) return true end,
    goOnPatrol = function(entity, param) return true end,

    hasNotEnemyInAttackRange = function(entity, param) return blackboard.hasNotEnemyInAttackRange end,
    isBigBoss = function(entity, param) return blackboard.bigBossValue >= param end,
    goToEnemy = function(entity, param) return true end,

    canReleaseSkill = function(entity, param) return blackboard.canReleaseSkill end,
    releaseSkill = function(entity, param) return true end,

    goHome = function(entity, param) return true end,
}

local tree = BehaviorTree:new(tree)
tree:run(entity)


