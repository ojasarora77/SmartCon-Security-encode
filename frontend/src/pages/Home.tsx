import React from 'react';
import CommonLoader from '../components/common-loader';

const Home: React.FC = () => {
    return <div className="h-screen w-screen flex place-content-center justify-items-center flex-col justify-center place-items-center">
        <CommonLoader></CommonLoader>
    </div>;
};

export default Home;
