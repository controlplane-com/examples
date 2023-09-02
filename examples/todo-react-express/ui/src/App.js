import React from "react";
import axios from "axios";

const BASE_URL = window.location.href.slice(0, -1);

console.log("Base URL", BASE_URL);

function App() {
  const [todos, setTodos] = React.useState([]);
  const [error, setError] = React.useState("");

  React.useEffect(() => {
    getEnvVars();
    getTodos();
  }, []);

  function handleError(e) {
    let errorMessage = e?.response?.data?.message;
    if (!errorMessage) errorMessage = e.message;
    setError(errorMessage);
  }

  async function getEnvVars() {
    try {
      const res = await axios.get(`${BASE_URL}/envvars`);
      console.log(res.data);
    } catch (e) {
      handleError(e);
    }
  }

  async function getTodos() {
    try {
      const res = await axios.get(`${BASE_URL}/todo`);
      setTodos(res.data);
    } catch (e) {
      handleError(e);
    }
  }

  async function toggleDone(e, id) {
    try {
      await axios.patch(`${BASE_URL}/todo/${id}`, {
        done: e.target.checked,
      });
      await getTodos();
    } catch (e) {
      handleError(e);
    }
  }

  async function removeTodo(id) {
    try {
      await axios.delete(`${BASE_URL}/todo/${id}`);
      await getTodos();
    } catch (e) {
      handleError(e);
    }
  }

  async function addTodo() {
    try {
      const form = document.querySelector("form");
      await axios.post(`${BASE_URL}/todo`, {
        title: form.title.value,
        description: form.description.value,
      });
      await getTodos();
      form.reset();
    } catch (e) {
      handleError(e);
    }
  }

  if (error) {
    return (
      <div className="w-screen h-screen flex flex-col items-center bg-gray-100 p-32">
        <div className="text-xl">Encountered an error: {error}</div>
        <button
          className="bg-gray-700 shadow border-white text-white px-4 py-2 mt-4 rounded cursor-pointer"
          onClick={() => window.location.reload()}
        >
          Refresh
        </button>
      </div>
    );
  }

  return (
    <>
      <div className="flex flex-col mt-16 items-center">
        <div className="text-3xl mb-4 text-gray-700">Todos</div>
        <div
          className="flex items-center px-4 py-2 border bg-gray-100 text-gray-700"
          style={{ width: 1000 }}
        >
          <div className="w-4/12" style={{ paddingLeft: 28 }}>
            Title
          </div>
          <div>Description</div>
        </div>
        {todos.map((todo) => {
          return (
            <div
              className="flex items-center px-4 py-2 border"
              style={{ width: 1000 }}
            >
              <div className="w-4/12 flex items-center">
                <input
                  className="mr-4"
                  checked={todo.done}
                  onChange={(e) => toggleDone(e, todo.id)}
                  type={"checkbox"}
                />
                <span className={`${todo.done ? "line-through" : ""}`}>
                  {todo.title}
                </span>
              </div>
              <div className="flex w-8/12 items-center justify-between">
                <span className={`${todo.done ? "line-through" : ""}`}>
                  {todo.description}
                </span>
                <button
                  className="text-red-600 cursor-pointer"
                  onClick={(e) => removeTodo(todo.id)}
                >
                  X
                </button>
              </div>
            </div>
          );
        })}
      </div>
      <div
        className="flex flex-col items-center mx-auto mt-8"
        style={{ width: 500 }}
      >
        <div className="text-2xl text-gray-700 mb-2">Add todo</div>
        <form
          className="flex flex-col w-full"
          onSubmit={(e) => {
            e.preventDefault();
            addTodo();
          }}
        >
          <label className="flex items-center mb-2">
            <span className="w-4/12">Title</span>
            <input className="pl-2 w-8/12 border bg-white" name="title" />
          </label>
          <label className="flex items-center">
            <span className="w-4/12">Description</span>
            <input className="pl-2 w-8/12 border bg-white" name="description" />
          </label>
          <button
            className="px-4 py-2 bg-green-100 text-green-600 border border-green-300 mt-2 w-32 self-end"
            type="submit"
          >
            Add
          </button>
        </form>
      </div>
    </>
  );
}

export default App;
