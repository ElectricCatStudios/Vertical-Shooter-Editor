PriorityQueue = newclass("PriorityQueue")

function PriorityQueue:init()
    self.rear = 1
    self.heap = {}
end

function PriorityQueue:Insert(data, priority)
    local currentPosition = self.rear
    local parentPosition = math.floor(self.rear/2)

    local node = {}
    node.data = data
    node.priority = priority
    self.heap[currentPosition] = node

    if(self.rear ~= 1) then
        -- Note: integer dividing the array index of a node always gives the index of the parent node
        while(self.heap[parentPosition].priority < self.heap[currentPosition].priority) do
            self.heap[currentPosition], self.heap[parentPosition] =
                    self.heap[parentPosition], self.heap[currentPosition]
            currentPosition = parentPosition
            parentPosition = math.floor(currentPosition/2)
            if (parentPosition == 0) then break end     -- we have reached the root of the tree
        end
    end

    self.rear = self.rear + 1
end

function PriorityQueue:Remove()
    local returnNode = self.heap[1]
    local currentPosition = 1
    local childAPosition = currentPosition*2
    local childBPosition = currentPosition*2 + 1

    if(not self.heap[1]) then
        return nil
    end

    self.heap[1] = self.heap[self.rear-1]
    self.heap[self.rear-1] = nil

    local swapWithA = nil
    local ordered = false

    repeat
        local swapWithA = (self.heap[childAPosition]) and
                ((not self.heap[childBPosition]) or
                (self.heap[childAPosition].priority > self.heap[childBPosition].priority))
        if(swapWithA) then
            if(self.heap[childAPosition].priority > self.heap[currentPosition].priority) then
                self.heap[childAPosition], self.heap[currentPosition] =
                        self.heap[currentPosition], self.heap[childAPosition]
                currentPosition = childAPosition
                childAPosition = currentPosition*2
                childBPosition = currentPosition*2 + 1
            else
                ordered = true
            end
        else
            if(self.heap[childBPosition] and
                    (self.heap[childBPosition].priority > self.heap[currentPosition].priority)) then
                self.heap[childBPosition], self.heap[currentPosition] =
                        self.heap[currentPosition], self.heap[childBPosition]
                currentPosition = childBPosition
                childAPosition = currentPosition*2
                childBPosition = currentPosition*2 + 1
            else
                ordered = true
            end
        end
    until(ordered)

    self.rear = self.rear - 1

    return returnNode.data, returnNode.priority
end

function PriorityQueue:IterateData()
    local i = 0
    local rear = self.rear
    return function()
        i = i + 1
        if i < rear then
            return self.heap[i].data
        end
    end
end

function PriorityQueue:Peek()
    return self.heap[1].data, self.heap[1].priority
end

function PriorityQueue:PrintHeap()
    print("Printing Heap:")
    for index, node in ipairs(self.heap) do
        print(index, node.priority)
    end
    print()
end

function PriorityQueue:Clone()
    newQueue = PriorityQueue:new()
    newQueue.rear = self.rear

    for i=1, self.rear-1 do
        newQueue.heap[i] = self.heap[i]
    end

    return newQueue
end
