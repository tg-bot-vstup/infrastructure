// available AZ
data "aws_availability_zones" "available" {
  state = "available"
}

// VPC
resource "aws_vpc" "main" {
  cidr_block = var.main_vpc_cidr
}

// Public subnet
resource "aws_subnet" "public" {
  count = var.availability_zones_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true // Public
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-${count.index}"
  }
}

// Private
resource "aws_subnet" "private" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, var.availability_zones_count + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-${count.index}"
  }
}

// IGW for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

// NAT for private subnets internet access
resource "aws_eip" "nat-eip" {
  count = var.availability_zones_count
  vpc   = true

  tags = {
    Name = "nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "natgw" {
  count = var.availability_zones_count

  allocation_id = aws_eip.nat-eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "natgw-${count.index}"
  }
}

resource "aws_route_table" "private" {
  count = var.availability_zones_count

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = {
    Name = "private-${count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count = var.availability_zones_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
