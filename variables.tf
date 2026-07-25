variable "filename"{
    type = string
    description = "This is a file path"
}

variable "file_content"{
    type = string
    description = "This is the file content"
}

variable "username"{
    type = string
    description = "This is the user's preferred name"
    default = "John Doe"
}


variable "user_id"{
    type = number
    description = " This is the user's id"
}

variable "environment"{
    type = string
    description = "This tells the current working environment in use"
    default = "dev"
}


variable "db_port"{
    type = number
    description = " This is the user's id"
    default = 1357
}
