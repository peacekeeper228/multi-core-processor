
            .text

addiu $t1, $0, 0
start:
addiu $t1, $t1, 1
sw $t1, 0($0)
beq $0, $0, start     
