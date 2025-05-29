# NWT dataobject to be implemented here


from scipy.io import readsav
import numpy as np
import io
import flap
import logging
import pickle


from nti_wavelet_tools.python.utility import convert_dict_to_flap

logging.basicConfig(filename='log.log',
                    filemode='w',
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    datefmt='%y.%b.%d. %H:%M:%S',
                    level=logging.INFO)
core_logger = logging.getLogger('core_logger')
core_logger.setLevel(logging.DEBUG)


class NWTDataObject:

    def __init__(self, logger=core_logger):
        # FLAP dataobjects to be filled:
        self.raw_data = None
        self.common_time = None
        self.channels = None
        self.transforms = None
        self.smoothed_apsds = None
        self.crosstransforms = None
        self.smoothed_crosstransforms = None
        self.coherences = None
        self.transfers = None
        self.modenumbers = None
        self.qs = None
        
        self.transform_parameters = {}

        self.logger = logger

        # properies if signals
        self.raw_datapoints = None

        self.logger.debug("NWT DataObject created")
        return

    def update_properties(self):
        if self.raw_data is not None:
            self.raw_datapoints = self.raw_data.data.shape[-1]

    def reset(self):
        self.__init__(logger=self.logger)

    def load_proc_sav(self, path):
        try:
            self.logger.info("Loading sav file: " + path)
            loaded_sav = readsav(path, python_dict=True)
            self.reset()
            self.raw_data, self.transforms, self.smoothed_apsds, self.crosstransforms, self.smoothed_crosstransforms, \
            self.coherences, self.transfers, self.modenumbers, self.qs, self.transform_parameters \
                = convert_dict_to_flap.convert_processed_sav(loaded_sav)
            self.update_properties()
        except Exception as e:
            self.logger.error("Exception occurred during processed sav loading:", exc_info=True)
        return

    def load_raw_sav(self, path):
        self.logger.info("Loading sav file: " + path)
        loaded_sav = readsav(path, python_dict=True)
        if "transf_timeax" in loaded_sav or "transf_freqax" in loaded_sav:
            self.logger.warning("Probably trying to load processed sav, please use 'Load processed' button")
            return
        try:
            self.reset()
            self.raw_data = convert_dict_to_flap.convert_raw_sav(loaded_sav)
            self.logger.debug("Loaded sav file")
        except TypeError('loaded_sav is not a dictionary of a raw sav file'):
            self.logger.error('loaded_sav is not a dictionary of a raw sav file', exc_info=True)
        except Exception as e:
            self.logger.error("Exception occurred during dict to flap conversion:", exc_info=True)
        self.update_properties()
        return

    def load_flap_raw_dump(self, path):
        self.logger.info('Loading flap object: ' + path)
        self.raw_data = flap.load(path)
        time = self.raw_data.coordinate('Time')[0]
        if len(time.shape) == 2:
            dt = time[1,0] - time[0,0]
            for i in range(time.shape[1]):
                if np.abs(np.max(time[:,i] - time[:,0])) > 1e-5*dt:
                    raise ValueError("Multiple different time axes.")
            time = time[:,0]
        elif len(time.shape) > 2:
            raise ValueError("Too many time dimensions.")
        self.common_time = time
        id = self.raw_data.coordinate('ADC Channel')[0][0]
        if len(id.shape) == 0:
            id = np.array([id])
        self.channels = id
        self.update_properties()
        return

    def save_raw_flap(self, path):
        filename = (path.split('/'))[-1] + '.flapdata'
        flap.save(self.raw_data, filename=filename)

    def load(self, path):
        if path[-6:] == ".pynwt":
            try:
                f = io.open(path, "rb")
                self.raw_data = pickle.load(f)
                self.transforms = pickle.load(f)
                self.smoothed_apsds = pickle.load(f)
                self.crosstransforms = pickle.load(f)
                self.smoothed_crosstransforms = pickle.load(f)
                self.coherences = pickle.load(f)
                self.transfers = pickle.load(f)
                self.modenumbers = pickle.load(f)
                self.qs = pickle.load(f)
                self.update_properties()
                f.close()
                return
            except Exception as e:
                core_logger.error('Error during loading', exc_info=True)
        else:

            return

    def save(self, path):
        if path[-6:] != ".pynwt":
            path = path + ".pynwt"
        try:
            f = open(path, "wb")
            pickle.dump(self.raw_data, f)
            pickle.dump(self.transforms, f)
            pickle.dump(self.smoothed_apsds, f)
            pickle.dump(self.crosstransforms, f)
            pickle.dump(self.smoothed_crosstransforms, f)
            pickle.dump(self.coherences, f)
            pickle.dump(self.transfers, f)
            pickle.dump(self.modenumbers, f)
            pickle.dump(self.qs, f)
            f.close()
            return
        except Exception as e:
            core_logger.error('Error during loading', exc_info=True)