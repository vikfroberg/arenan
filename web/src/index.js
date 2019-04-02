import './reset.css';
import './main.css';
import './animate.css';
import { Main } from './Main.elm';

const app = Main.embed(document.getElementById('root'), {
  api: "http://localhost:5000",
  playerId: getLocalStorageItem("playerId")
});

app.ports.storageGetItem.subscribe(storageGetItem);
app.ports.storageSetItem.subscribe(storageSetItem);
app.ports.storageRemoveItem.subscribe(storageRemoveItem);
app.ports.storageClear.subscribe(storageClear);

function storageGetItem(key) {
  const response = getLocalStorageItem(key);
  app.ports.storageGetItemResponse.send([key, response]);
}

function storageSetItem([key, value]) {
  setLocalStorageItem(key, value);
  app.ports.storageSetItemResponse.send([key, value]);
}

function storageRemoveItem(key) {
  window.localStorage.removeItem(key);
}

function storageClear() {
  window.localStorage.clear();
}

/**
 * Get a JSON serialized value from localStorage. (Return the deserialized version.)
 *
 * @param  {String} key Key in localStorage
 * @return {*}      The deserialized value
 */
function getLocalStorageItem(key) {
  try {
    return JSON.parse(
      window.localStorage.getItem(key)
    );
  } catch (e) {
    return null;
  }
}

/**
 * Set a value of any type in localStorage.
 * (Serializes in JSON before storing since Storage objects can only hold strings.)
 *
 * @param {String} key   Key in localStorage
 * @param {*}      value The value to set
 */
function setLocalStorageItem(key, value) {
  window.localStorage.setItem(key,
    JSON.stringify(value)
  );
}
