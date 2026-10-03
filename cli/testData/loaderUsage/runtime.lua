local Example = QuestieLoader:CreateModule("LoaderUsageFixture")

function Example.Update()
    local Dependency = QuestieLoader:ImportModule("Dependency")
    return Dependency
end
