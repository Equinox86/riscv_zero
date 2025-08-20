import os

class instruction:
    def __init__(self, shorthand,  opcode, funct3, funct7, itype):
        self.shorthand = shorthand
        self.opcode = opcode
        self.funct3 = funct3
        self.funct7 = funct7
        self.itype = itype

instructions = {
    "RV32I":[
        instruction("lb", 3,0,None,"I"),
        instruction("lh", 3,1,None,"I"),
        instruction("lw",3,2,None,"I"),
        instruction("lbu",3,4,None,"I"),
        instruction("lhu", 3,5,None,"I"),
        instruction("addi", 19,0,None,"I"),
        instruction("slli", 19,1,None,"I"),
        instruction("slti", 19,2,None,"I"),
        instruction("sltiu",19,3,None,"I"),
        instruction("xori", 19,4,None,"I"),
        instruction("srli",19,5,None,"I"),
        instruction("srai",19,5,32,"I"),
        instruction("ori",19,6,None,"I"),
        instruction("andi",19,7,None,"I"),
        instruction("auipic",23,None,None,"U"),
        instruction("sb",35,0,None,"S"),
        instruction("sh",35,1,None,"S"),
        instruction("sw",35,3,None,"S"),
        instruction("add",51,0,None,"R"),
        instruction("sub",51,0,32,"R"),
        instruction("sll",51,1,None,"R"),
        instruction("slt",51,2,None,"R"),
        instruction("sltu",51,3,None,"R"),
        instruction("xor",51,4,None,"R"),
        instruction("srl",51,5,None,"R"),
        instruction("sra",51,5,32,"R"),
        instruction("or",51,6,None,"R"),
        instruction("and",51,7,None,"R"),
        instruction("lui",55,None,None,"U"),
        instruction("beq",99,0,None,"B"),
        instruction("bne",99,1,None,"B"),
        instruction("blt",99,4,None,"B"),
        instruction("bge",99,5,None,"B"),
        instruction("bltu",99,6,None,"B"),
        instruction("bgeu", 99,7,None,"B"),
        instruction("jalr", 103,0,None,"I"),
        instruction("jal", 111,None,None,"J")
    ],
    "RV64I":[
        instruction("ld",3,3,None,"I"),
        instruction("lwu",3,6,None,"I"),
        instruction("addiw",27,0,None,"I"),
        instruction("slliw",27,1,None,"I"),
        instruction("srlliw",27,5,None,"I"),
        instruction("sraiw",27,6,32,"I"),
        instruction("sd",35,3,None,"S"),
        instruction("addw",59,0,None,"R"),
        instruction("subw",59,0,32,"R"),
        instruction("sllw",59,1,None,"R"),
        instruction("srlw",59,5,None,"R"),
        instruction("sraw",59,5,32,"R"),
    ]
}

mem_filepath = input("Specify a filename:")
access = 'w'
if os.path.exists(mem_filepath):
    overwrite = input("This file exists, do you want to overwrite? y/n")
    if overwrite not in ["y", "Y", "yes"]:
        access = 'a'
mem_file = open(mem_filepath, access)

loading = True
while loading:
    spec = input("Specify revision: ").upper()
    if spec not in instructions.keys():
        print("Invalid RISC-V specifcation - see help (-h)")
        continue

    # Fixed Values
    rs1 = 5
    rs2 = 6
    rd = 7
    immediate = 2731

    instruction_list = instructions[spec]
    for inst in instruction_list:
        funct7 =  inst.funct7 if inst.funct7 else 0
        funct3 =  inst.funct3 if inst.funct3 else 0
        if inst.itype == "R":
            out_inst = (funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 | rd << 7| inst.opcode)
        elif inst.itype == "I":
            out_inst = (immediate << 20 | rs2 << 15 | funct3  << 12 | rd << 7 | inst.opcode)
        elif inst.itype == "S":
            out_inst = ((immediate & 0xFE0) << 20 | rs1 << 20 |  rs1 << 15 | funct3 << 12 | (immediate & 0x1F) << 7 | inst.opcode)
        elif inst.itype == "U":
            out_inst = (immediate & 0xFFFFF000 | rd << 7 | inst.opcode)
        elif inst.itype == "B":
            out_inst = ((immediate & 0x1000) << 19  | (immediate & 0x7E0) << 20 | rs2 << 20 | rs1 << 15 | funct3 << 12 | (immediate & 0x1E) << 7| (immediate & 0x800) >> 4 | inst.opcode)
        elif inst.itype == "J":
            out_inst = ((immediate & 0x100000) << 11 | (immediate & 0x7FE) << 20 | (immediate & 0x800) << 9| (immediate & 0xFF000) | rd << 7 | inst.opcode)
        out_inst &= 0xFFFFFFFF

        mem_file.write(f"{format(out_inst, '08X')}\n")


    keep_loading = input("Load another revision?: ")
    if keep_loading not in  ["y", "Y", "yes"]:
        mem_file.close()
        loading = False

