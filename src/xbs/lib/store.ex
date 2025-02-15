defmodule XBS.Store do
  def new(state \\ %{}) do
    store = :ets.new(__MODULE__, [:set, :protected])
    Enum.each(state, fn {k, v} -> :ets.insert(store, {k, :val, v}) end)
    store
  end
  
  def get(store, key) do
    case :ets.lookup(store, key) do
      [] -> raise XBS.KeyNotFoundError, key: key
      [{^key, :val, val}] -> val
      [{^key, :task, task}] ->
	result = task.(store)
	:ets.insert(store, {key, :val, result})
	result
    end
  end

  def add_task(store, key, task) do
    :ets.insert(store, {key, :task, task})
  end
end
